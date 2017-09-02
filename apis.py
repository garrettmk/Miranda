from PyQt5 import QtCore, QtNetwork
from datetime import datetime, timedelta, timezone
from collections import deque
from models import *
import amazonmws as mws
import amzkeys


########################################################################################################################


class API(QtCore.QObject):
    """Provides an abstract interface to outside APIs (like Amazon's MWS API). Converts APICall objects into actual
    network requests, and handles throttling."""

    def __init__(self, *args, network=None, **kwargs):
        super().__init__(*args, **kwargs)
        self._network = network
        self._running = False

    @property
    def network(self):
        return self._network

    @network.setter
    def network(self, value):
        self._network = value
    
    @QtCore.pyqtSlot(APICall, result=bool)
    def enqueue(self, api_call):
        """Enqueues an APICall object."""

    @QtCore.pyqtSlot(APICall)
    def cancel(self, api_call):
        """Remove an APICall from the queue."""

    @QtCore.pyqtSlot(result=bool)
    def available(self):
        """Return True if the API is available and ready for use."""
        raise NotImplementedError

    runningChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=runningChanged)
    def running(self):
        return self._running

    def set_running(self, value):
        self._running = bool(value)
        self.runningChanged.emit()

    @QtCore.pyqtSlot()
    def start(self):
        """Start processing API calls."""
        self.set_running(True)

    @QtCore.pyqtSlot()
    def stop(self):
        """Stop processing API calls."""
        self.set_running(False)


########################################################################################################################


class AmazonThrottledQueueAPI(API):
    """Contains the multi-action throttled queue behavior used by AmazonMWS and AmazonPA."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._deques = {}
        self._timers = {}
        self._replies = {}
        self._retries = {}
        self._wait_on_retry = 5000

    def next_api_call(self, action):
        """Convenience method, returns the APICall object for the next request of type :action:."""
        try:
            return self._deques[action][0]
        except (KeyError, IndexError):
            return None

    def make_request(self, action, **kwargs):
        """Returns a QNetworkReply for the given API action."""
        raise NotImplementedError

    def make_qnetwork_request(self, *args, **kwargs):
        """Translates a request from the internal API object into a QNetworkRequest."""
        url = QtCore.QUrl(kwargs['url'])
        request = QtNetwork.QNetworkRequest(url)

        for k, v in kwargs['headers'].items():
            request.setRawHeader(k.encode(), v.encode())

        return self.network.sendCustomRequest(request, kwargs['method'].encode(), kwargs['data'])

    def _calculate_wait(self, action):
        """Return the amount of time, in milliseconds, before a request for the given api call can be sent."""
        return 0

    @QtCore.pyqtSlot(QtCore.QVariant)
    def processNext(self, action=None):
        """Processes the next action in the given queue, or in all queues if action=None."""
        actions = list(self._deques.keys()) if action is None else [action]
        actions = [act for act in actions if act in self._deques and len(self._deques[act]) > 0]
        actions = [act for act in actions if self._timers.get(act, None) is None]

        for act in actions:
            wait = self._calculate_wait(act) + self._retries.get(act, 0) * self._wait_on_retry
            timer_id = self.startTimer(wait, QtCore.Qt.PreciseTimer)
            self._timers[act] = timer_id

    def timerEvent(self, event):
        """Initiates a request."""
        timer_id = event.timerId()
        action = [act for act, t_id in self._timers.items() if t_id == timer_id][0]
        self.killTimer(timer_id)
        self._timers[action] = None

        api_call = self._deques[action][0]
        parameters = api_call.parameters or {}

        self._replies[action] = self.make_request(action, **parameters)
        self._replies[action].finished.connect(lambda action=action: self._process_api_response(action))

    def _process_api_response(self, action):
        """Receives the finished() signal for the current network request, and finishes processing the api call"""
        api_call = self._deques[action][0]
        reply = self._replies[action]
        error = reply.error()

        if error == QtNetwork.QNetworkReply.NoError:
            pass
        elif error in [QtNetwork.QNetworkReply.ServiceUnavailableError,
                       QtNetwork.QNetworkReply.UnknownNetworkError]:
            # This pretty much always means the request was throttled
            if self._retries.get(action, 0) < 2:
                self._retries[action] = self._retries.get(action, 0) + 1
                print(f'Throttled ({action}), retry {self._retries[action]}')
                self.processNext(action)
                return
            else:
                print(f'Throttled ({action}), no more retries.')
        else:
            print(error, reply.errorString())

        self._retries[action] = 0
        api_call.rawResponse = reply.readAll().data().decode()
        api_call.finished.emit()

        self._deques[action].popleft()
        if self.running:
            self.processNext(action)

    @QtCore.pyqtSlot()
    def start(self):
        super().start()
        self.processNext()

    @QtCore.pyqtSlot(AmazonMWSCall)
    def enqueue(self, api_call):
        """Adds an API call to the processing queue."""
        action = api_call.action

        if action not in self._deques:
            self._deques[action] = deque()

        self._deques[action].append(api_call)

        if self.running:
            self.processNext(action)

    @QtCore.pyqtSlot(AmazonMWSCall)
    def cancel(self, api_call):
        action = api_call.action

        try:
            idx = self._deques[action].index(api_call)
        except (KeyError, ValueError):
            return

        if idx == 0 and self.running:
            return
        else:
            self._deques[action].remove(api_call)


########################################################################################################################


class AmazonMWS(AmazonThrottledQueueAPI):
    """Provides an interface to the Amazon Market Web Services API."""

    def __init__(self, *args, running=False, **kwargs):
        super().__init__(*args, **kwargs)
        self._api = mws.Products(amzkeys.mws_access_id, amzkeys.mws_secret_key, amzkeys.mws_seller_id)
        self._api.make_request = self.make_qnetwork_request

        # Throttling info
        self._min_wait = 100
        self._quota_levels = {}
        self._last_quota_updates = {}

        if running:
            self.start()

    def _quota_count(self, api_call):
        """Returns the number of quota slots an api call will take."""
        if api_call.api == 'AmazonPA':
            return 1

        params = api_call.parameters
        for key, value in params.items():
            if 'list' in key.lower():
                return len(value)

        return 1

    def make_request(self, action, **kwargs):
        """Make a request for the given API action, and return the resulting QNetworkReply object."""
        elapsed = datetime.now() - self._last_quota_updates[action]
        print(f'action: {action}, elapsed: {round(elapsed.total_seconds(), 3)} sec')
        api_call = self.next_api_call(action)
        self._quota_levels[action] = self._quota_levels.get(action, 0) + self._quota_count(api_call)
        return getattr(self._api, action)(**kwargs)

    def _calculate_wait(self, action):
        """Return the amount of time, in milliseconds, before a request for the given action can be sent."""
        call_type = qp.MapObject.subclass(action)
        quota_max = getattr(call_type, 'quota_max', 1)
        restore_rate = getattr(call_type, 'restore_rate', 1)
        hourly_max = getattr(call_type, 'hourly_max', 3600)

        now = datetime.now()
        last_update = self._last_quota_updates.get(action, now)
        elapsed = now - last_update
        fully_restored = elapsed.total_seconds() // restore_rate
        partial_restore = elapsed.total_seconds() % restore_rate

        quota_level = self._quota_levels.get(action, 0) + self._retries.get(action, 0)
        quota_level = max(quota_level - fully_restored, 0)
        quota_count = self._quota_count(self.next_api_call(action))

        if (quota_level + quota_count) < quota_max:
            wait = 0
        else:
            wait = (quota_level + quota_count - quota_max) * restore_rate + (restore_rate - partial_restore) * 1000

        print(f'action: {action}, quota_level: {quota_level}, quota_count: {quota_count}, wait: {wait}')

        self._quota_levels[action] = quota_level
        self._last_quota_updates[action] = now - timedelta(seconds=partial_restore)

        return wait

    @QtCore.pyqtSlot(result=bool)
    def available(self):
        """Return True if this API can process requests."""
        if self.network.networkAccessible() != QtNetwork.QNetworkAccessManager.Accessible:
            return False

        loop = QtCore.QEventLoop()
        reply = self._api.GetServiceStatus()
        reply.finished.connect(loop.quit)
        loop.exec()

        if reply.error() != QtNetwork.QNetworkReply.NoError:
            return False

        status_call = GetServiceStatus(rawResponse=reply.readAll().data().decode())
        return status_call.status == 'GREEN'


########################################################################################################################


class AmazonPA(AmazonThrottledQueueAPI):
    """Provides an interface to the Amazon Product Advertising API."""

    def __init__(self, *args, running=False, **kwargs):
        super().__init__(*args, **kwargs)
        self._api = mws.ProductAdvertising(amzkeys.pa_access_key, amzkeys.pa_secret_key, amzkeys.pa_associate_tag)
        self._api.make_request = self.make_qnetwork_request

        # Throttling info
        self._min_wait = 1000
        self._last_request = datetime.fromtimestamp(0)

        if running:
            self.start()

    def make_request(self, action, **kwargs):
        print(f'action: {action}')
        self._last_request = datetime.now()
        return getattr(self._api, action)(**kwargs)

    def _calculate_wait(self, action):
        """Return the amount of time, in milliseconds, before a request for the given action can be sent."""
        now = datetime.now()
        elapsed_ms = (now - self._last_request).total_seconds() * 1000

        wait = max(self._min_wait - elapsed_ms, 0)
        return wait

    @QtCore.pyqtSlot(result=bool)
    def available(self):
        return self.network.networkAccessible() == QtNetwork.QNetworkAccessManager.Accessible