import 'package:flutter/cupertino.dart';
import 'package:user/Models/address.dart';

import '../Models/address.dart';

class AppData extends ChangeNotifier {
  late Address pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
