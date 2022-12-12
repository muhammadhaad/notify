import 'dart:convert';

class DataModel {
    DataModel({
        required this.time,
        required this.cryptoCurrency,
        required this.rate,
    });

    String time;
    String cryptoCurrency;
    double rate;

    factory DataModel.fromRawJson(String str) => DataModel.fromJson(json.decode(str));



    factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
        time: json["time"],
        cryptoCurrency: json["asset_id_base"],
        rate: json["rate"].toDouble(),
    );

}
