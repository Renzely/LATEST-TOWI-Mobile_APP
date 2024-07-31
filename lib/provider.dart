import 'package:flutter/foundation.dart';

class AttendanceModel extends ChangeNotifier {
  String? _timeIn;
  String? _timeOut;
  bool _isTimeInRecorded = false;
  bool _isTimeOutRecorded = false;

  String? get timeIn => _timeIn;
  String? get timeOut => _timeOut;
  bool get isTimeInRecorded => _isTimeInRecorded;
  bool get isTimeOutRecorded => _isTimeOutRecorded;

  void updateTimeIn(String? timeIn) {
    _timeIn = timeIn;
    notifyListeners();
  }

  void updateTimeOut(String? timeOut) {
    _timeOut = timeOut;
    notifyListeners();
  }

  void setIsTimeInRecorded(bool isRecorded) {
    _isTimeInRecorded = isRecorded;
    notifyListeners();
  }

  void setIsTimeOutRecorded(bool isRecorded) {
    _isTimeOutRecorded = isRecorded;
    notifyListeners();
  }

  void reset() {
  _timeIn = null;
  _timeOut = null;
  _isTimeInRecorded = false;
  _isTimeOutRecorded = false;
  notifyListeners();
}

}