import re
import cupi as qp
from PyQt5 import QtCore, QtQml
from models import Product


########################################################################################################################


class Validator(QtCore.QObject):

    property_name = ''

    def __init__(self, *args, product=None, always_apply=False, **kwargs):
        super().__init__(*args, **kwargs)
        self._isValid = False
        self._guess = None
        self._guessIsValid = False
        self._always_apply = always_apply
        self._enabled = True
        self._product = None
        self.product = product

    enabledChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=enabledChanged)
    def enabled(self):
        return self._enabled

    @enabled.setter
    def enabled(self, value):
        self._enabled = value
        self.enabledChanged.emit()

    propertyNameChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(str, notify=propertyNameChanged)
    def propertyName(self):
        return self.property_name

    productChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant)
    def product(self):
        return self._product

    @product.setter
    def product(self, value):
        if value is not None and not isinstance(value, Product):
            raise ValueError('Must be an instance of Product, or None.')

        if self._product is not None:
            try:
                signal = getattr(self._product, self.property_name + 'Changed')
                signal.disconnect(self.currentValueChanged)
                signal.disconnect(self._do_checks)
            except (AttributeError, TypeError):
                pass

        if value is not None:
            try:
                signal = getattr(value, self.property_name + 'Changed')
                signal.connect(self.currentValueChanged)
                signal.connect(self._do_checks)
            except (AttributeError, TypeError):
                pass

        self._product = value
        self.productChanged.emit()
        self.currentValueChanged.emit()
        self._do_checks()

    def _do_checks(self):
        if self._product is None:
            self._isValid = False
            self._guess = None
            self._guessIsValid = False
        else:
            self._isValid = self.check(self.currentValue)
            self._guess = self.make_guess(self.currentValue)
            self._guessIsValid = self.check(self.guess)

        if self._always_apply \
                and not self.isValid \
                and self.guessIsValid:
            self.apply()
            self._isValid = True

        self.isValidChanged.emit()
        self.guessChanged.emit()
        self.guessIsValidChanged.emit()

    currentValueChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=currentValueChanged)
    def currentValue(self):
        return getattr(self.product, self.property_name, None)

    @currentValue.setter
    def currentValue(self, value):
        value = value.toVariant() if isinstance(value, (QtCore.QVariant, QtQml.QJSValue)) else value
        setattr(self.product, self.property_name, value)

    @QtCore.pyqtSlot(str, result=bool)
    def setCurrentValueWithEval(self, eval_str):
        try:
            self.currentValue = eval(eval_str)
        except:
            return False

        return True

    isValidChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=isValidChanged)
    def isValid(self):
        return self._isValid

    guessChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=guessChanged)
    def guess(self):
        return self._guess

    @guess.setter
    def guess(self, value):
        self._guess = value
        self._guessIsValid = self.check(value)
        self.guessChanged.emit()
        self.guessIsValidChanged.emit()

    guessIsValidChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=guessIsValidChanged)
    def guessIsValid(self):
        return self._guessIsValid

    @QtCore.pyqtSlot(str, result=bool)
    def setGuessWithEval(self, guess):
        try:
            self.guess = eval(guess)
            return True
        except:
            return False

    useGuessChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=useGuessChanged)
    def useGuess(self):
        return bool(self._use_guess)

    @useGuess.setter
    def useGuess(self, value):
        self._use_guess = value

    saveGuessChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=saveGuessChanged)
    def saveGuess(self):
        return bool(self._save_guess)

    @saveGuess.setter
    def saveGuess(self, value):
        self._save_guess = value

    @QtCore.pyqtSlot()
    def apply(self):
        if not self.enabled or self.product is None:
            return

        product = self._product
        if not self.isValid:
            if '_validation' not in product:
                product['_validation'] = {}
            product['_validation'][str(self.currentValue)] = self.guess

        self.currentValue = self.guess

    alwaysApplyChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=alwaysApplyChanged)
    def alwaysApply(self):
        return self._always_apply

    @alwaysApply.setter
    def alwaysApply(self, value):
        self._always_apply = value
        self.alwaysApplyChanged.emit()

    def check(self, value):
        raise NotImplementedError

    def make_guess(self, value):
        raise NotImplementedError


########################################################################################################################


class PriceValidator(Validator):

    property_name = 'price'
    number_regex = re.compile(r'(\d+(?:\.\d+))')

    def check(self, value):
        if isinstance(value, float):
            return True
        else:
            return False

    def make_guess(self, value):
        # Try a simple float conversion first
        try:
            return float(value)
        except ValueError:
            pass

        try:
            price = str(value).replace(',', '')
        except ValueError:
            return None

        numbers = self.number_regex.findall(price)
        if len(numbers) != 1:
            return None

        try:
            return float(numbers[0])
        except ValueError:
            return None


########################################################################################################################


class QuantityValidator(Validator):

    property_name = 'quantity'

    def __init__(self, *args, map=None, **kwargs):
        super().__init__(*args, **kwargs)
        self._map = map if map is not None else {}

    mapChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=mapChanged)
    def map(self):
        return self._map

    @map.setter
    def map(self, value):
        self._map = value.toVariant() if isinstance(value, (QtCore.QVariant, QtQml.QJSValue)) else value
        self.mapChanged.emit()

    def check(self, value):
        if isinstance(value, int) \
                and value > 0 \
                and (value in [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 16, 18]
                     or not value % 5
                     or not value % 10
                     or not value % 12):
            return True
        else:
            return False

    def make_guess(self, value):

        # Try to coerce it to int first
        try:
            return int(value)
        except (ValueError, TypeError):
            pass

        # All the next tests depend on it being a string, so get it ready
        try:
            value = str(value).lower().strip().replace(',', '')
        except ValueError:
            return None

        # Check if we've already come across this phrase before
        try:
            return self._map[value]
        except KeyError:
            pass

        # Check the title
        title = self.product.title.lower()
        for key, value in self._map.items():
            if key in title:
                return value

        return None


    @QtCore.pyqtSlot()
    def saveGuess(self):
        self._map[str(self.currentValue).lower().strip()] = self.guess


########################################################################################################################


class RankValidator(Validator):

    property_name = 'rank'
    number_regex = re.compile(r'(\d+)')

    def check(self, value):
        if isinstance(value, int)\
                and value > 0:
            return True
        else:
            return False

    def make_guess(self, value):
        try:
            return int(value)
        except (ValueError, TypeError):
            pass

        try:
            value = str(value).lower().strip().replace(',', '')
        except (ValueError, TypeError):
            return None

        numbers = self.number_regex.findall(value)
        if len(numbers) != 1:
            return None

        try:
            return int(numbers[0])
        except ValueError:
            return None