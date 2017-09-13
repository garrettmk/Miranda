import re
from PyQt5 import QtCore, QtQml
from models import Product, QuantityValidatorData


########################################################################################################################


class ProductValidator(QtCore.QObject):
    """Base class for property validators. Each validator works on a specific property, given by property_name. The
    current value can be checked using the check() method, and a guess can be generated using the make_guess()
    method.

    Attributes:
            property_name:      The name of the property that this validator operates on.

    """

    property_name = ''

    def __init__(self, *args, product=None, always_apply=False, **kwargs):
        """Initialize the validator."""
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
        """Enables or disables the validator. If the validator is disabled, calls to apply() will do nothing."""
        return self._enabled

    @enabled.setter
    def enabled(self, value):
        self._enabled = value
        self.enabledChanged.emit()

    propertyNameChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(str, notify=propertyNameChanged)
    def propertyName(self):
        """The name of the property that this validator class operates on. Provided for convenient access from QML."""
        return self.property_name

    productChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant)
    def product(self):
        """Return the current product."""
        return self._product

    @product.setter
    def product(self, value):
        """Set the current product. Setting the product connects to it's property change signals, enabling automatic
        re-checking when the value is changed (directly, or by setting currentValue)."""
        if value is not None and not isinstance(value, Product):
            raise ValueError('Must be an instance of Product, or None.')

        # Disconnect from the current product
        if self._product is not None:
            try:
                signal = getattr(self._product, self.property_name + 'Changed')
                signal.disconnect(self.currentValueChanged)
                signal.disconnect(self._do_checks)
            except (AttributeError, TypeError):
                pass

        # Connect to the new product
        if value is not None:
            try:
                signal = getattr(value, self.property_name + 'Changed')
                signal.connect(self.currentValueChanged)
                signal.connect(self._do_checks)
            except (AttributeError, TypeError):
                pass

        # Set state and emit change signals
        self._product = value
        self.productChanged.emit()
        self.currentValueChanged.emit()

        # Check the new product
        self._do_checks()

    def _do_checks(self):
        """Check the current product. check() and guess () are both called with the property's current value, and
        check() is called on the generated guess. isValid, guess, and guessIsValid are all updated accordingly. If
        alwaysApply is True, apply() is called if the current value is invalid but the generated guess is valid. If
        current product is None, guess is set to None and isValid and guessIsValid are both set to False."""

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
        """Convenience method for accessing the current product's property value. If the current product is None,
        currentValue is None."""
        return getattr(self.product, self.property_name, None)

    @currentValue.setter
    def currentValue(self, value):
        """Convenience method for setting the current product's property value. Automatically converts QVariants and
        QJSValues to their Python equivalents. Raises AttributeError if the current product is None. """
        value = value.toVariant() if isinstance(value, (QtCore.QVariant, QtQml.QJSValue)) else value
        setattr(self.product, self.property_name, value)

    @QtCore.pyqtSlot(str, result=bool)
    def setCurrentValueWithEval(self, eval_str):
        """Sets currentValue to eval(eval_str). Returns True if the operation was successful, or False if an exception
        was raised. This method provides simple way to differentiate between string values and ints/floats from within
        QML."""
        try:
            self.currentValue = eval(eval_str)
        except:
            return False

        return True

    isValidChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(bool, notify=isValidChanged)
    def isValid(self):
        """True if check(currentValue) is True."""
        return self._isValid

    guessChanged = QtCore.pyqtSignal()
    @QtCore.pyqtProperty(QtCore.QVariant, notify=guessChanged)
    def guess(self):
        """The guessed value generated by make_guess(). Setting this value will cause check(guess) to called and
        guessIsValid to be re-set."""
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
        """True if check(guess) is True."""
        return self._guessIsValid

    @QtCore.pyqtSlot(str, result=bool)
    def setGuessWithEval(self, guess):
        """Similar to setCurrentValueWithEval(), but sets guess instead."""
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


class PriceValidator(ProductValidator):

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


class QuantityValidator(ProductValidator):

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
        guess_map = self._map.map if isinstance(self._map, QuantityValidatorData) else self._map

        # Try to coerce it to int first
        try:
            return int(value)
        except (ValueError, TypeError):
            pass

        # Check if we've already come across this phrase before
        try:
            value = str(value).lower().strip().replace(',', '')
            return guess_map[value]
        except (KeyError, ValueError):
            pass

        sorted_guess_map = sorted(guess_map.items(),
                                  key=lambda tup: len(tup[0]),
                                  reverse=True)
        # Check the title
        title = self.product.title.lower()
        for key, value in sorted_guess_map:
            if key in title:
                return value

        # Check the product features
        features = self.product.get('features', '')
        if features:
            for key, value in sorted_guess_map:
                if key in features:
                    return value

        # Check the description
        description = self.product.get('description', '')
        if description:
            for key, value in sorted_guess_map:
                if key in description:
                    return value

        # Check NumberOfItems and PackageQuantity
        num_items = self.product.get('NumberOfItems', 0)
        pack_quant = self.product.get('PackageQuantity', 0)
        guess = max(num_items, pack_quant)

        return guess if guess > 0 else None


    @QtCore.pyqtSlot()
    def saveGuess(self):
        current = str(self.currentValue).lower().strip()
        if isinstance(self._map, QuantityValidatorData):
            self._map.map[current] = self.guess
        else:
            self._map[current] = self.guess


########################################################################################################################


class RankValidator(ProductValidator):

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