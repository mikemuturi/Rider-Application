// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/DataHandler/appData.dart';
import 'package:user/Models/address.dart';
import 'package:user/Models/direction_detail.dart';
import 'package:user/assistant/request_assistant.dart';

import '../global/map_key.dart';

class AssistantMethonds {
  static int? get distanceValue => null;

  static int? get directionValue => null;

  static Future searchCoordinateAddress(Position position, context) async {
    String placeAddress = " ";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAr1Iv-1Dc6YxyNlYnVZWqXijfXBOJJgRw";

    var response = await RequestAssistant.getRequest(url);

    if (response != "Failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response['results'][0]["address_components"][4]["long_name"];
      st2 = response['results'][0]["address_components"][7]["long_name"];
      st3 = response['results'][0]["address_components"][6]["long_name"];
      st4 = response['results'][0]["address_components"][9]["long_name"];
      placeAddress = st1 + "," + st2 + "," + st3 + "," + st4 + " ";

      var latitude;
      var longitude;
      Address userPickUpAddress = new Address(
          "placeFormattedAddress", "placeName", "placeId", latitude, longitude);
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey';

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(distanceValue!,
        directionValue!, "distanceText", "directionText", "encodedPoints");

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculatefares(DirectionDetails directionDetails) {
    double timeTravelledFare = (directionDetails.durationValue / 60) * 20;
    double distanceTravelledFare =
        (directionDetails.distanceValue / 1000) * 200;
    double totalFareAmount = timeTravelledFare + distanceTravelledFare;

    return totalFareAmount.truncate();
  }
}
