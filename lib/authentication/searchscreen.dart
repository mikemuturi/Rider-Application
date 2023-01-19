import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/DataHandler/appData.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user/Models/address.dart';
import 'package:user/Models/place_prediction.dart';
import 'package:user/widgets/divider.dart';

import '../assistant/request_assistant.dart';
import '../global/map_key.dart';
import '../mainScreens/main_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionsList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? " ";
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 255.0,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ]),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text(
                          "Drop off",
                          style: TextStyle(
                              fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 15.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            controller: pickUpTextEditingController,
                            decoration: InputDecoration(
                              hintText: "pick up location",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 11.0, top: 8.0, bottom: 8.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 15.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            onChanged: (val) {
                              findPlace(val);
                            },
                            controller: dropOffTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Destination location",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 11.0, top: 3.0, bottom: 3.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          (placePredictionsList.length > 0)
              ? Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePredictions: placePredictionsList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionsList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          " https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:ke";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == 'failed') {
        return;
      }
      if (res['status'] == 'Ok') {
        var predictions = res["predictions"];
        var PlacesPredictions;
        var placesList = (predictions as List)
            .map((e) => PlacesPredictions.fromJson(e))
            .toList();
        setState(() {
          var placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  PredictionTile({Key? key, required this.placePredictions}) : super(key: key);

  double? get latitude => null;
  double? get longitude => null;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      Padding: EdgeInsets.all(0.0),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      Child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      placePredictions.main_text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 30.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      placePredictions.secondary_text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.0, color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    ); //FlatButton
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Setting DropOff.please wait...."),
    );

    String placeDetailsurl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var res = await RequestAssistant.getRequest(placeDetailsurl);

    Navigator.pop(context);

    if (res == 'failed') {
      return;
    }
    if (res["status"] == ["Ok"]) {
      Address address = Address("placeFormattedAddress", "placeName", "placeId",
          latitude!, longitude!);
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print("This is Drop Off Location");

      print(address.placeName);

      Navigator.pop(context, 'obtainDirections');
    }
  }
}

FlatButton(
    {required EdgeInsets Padding,
    required Null Function() onPressed,
    required Container Child}) {}
