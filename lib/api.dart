import 'package:http/http.dart' as http;
Future<void> getCryptoPrice()async{
  var headers = {
  'X-CoinAPI-Key': '17272955-6008-4446-ADE0-762A686E5D88'
};
var response = http.Request('GET', Uri.parse('https://rest.coinapi.io/v1/exchangerate/BTC/PKR'));
response.headers.addAll(headers);
}