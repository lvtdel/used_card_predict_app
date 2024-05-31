import 'dart:async';
import 'dart:convert';

import 'package:car_used_price_predict/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('Dự đoán giá xe cũ')),
            backgroundColor: Colors.blue,
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: MyColumnWidget(),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyColumnWidget extends StatefulWidget {
  const MyColumnWidget({super.key});

  @override
  _MyColumnWidgetState createState() => _MyColumnWidgetState();
}

class _MyColumnWidgetState extends State<MyColumnWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  Timer? _timer;
  String priceRUB = "";
  String priceVND = "";
  String state = Constants.input_state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isWideDevice = constraints.maxWidth > 600;

            return Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFieldCustom(
                      controller1: _controller1, field: 'Car mileage'),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(controller1: _controller2, field: 'Car age (Year)'),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(
                      controller1: _controller3, field: 'Car engine hp'),
                  const SizedBox(height: 16.0),
                  _buildResult(state)

                  // const SizedBox(height: 16.0),
                  // Center(
                  //     child: SizedBox(
                  //       height: 60,
                  //       child: ElevatedButton(
                  //           onPressed: _submit,
                  //           child: Text(
                  //             'Dự đoán',
                  //             style: TextStyle(fontSize: isWideDevice ? 20 : 15),
                  //           )),
                  //     ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller1.removeListener(_onTextChanged);
    _controller2.removeListener(_onTextChanged);
    _controller3.removeListener(_onTextChanged);
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller3.addListener(_addTextListener);
  }

  _addTextListener() {
    _controller1.addListener(_onTextChanged);
    _controller2.addListener(_onTextChanged);
    _controller3.addListener(_onTextChanged);

    _controller3.removeListener(_addTextListener);
  }

  void _onTextChanged() {

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), () {
      _submit();
    });
  }

  _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        // priceVND = "";
        // priceRUB = "";
        state = Constants.input_state;
      });

      return;
    }
    _formKey.currentState!.save();

    _fetch();
  }

  _fetch() async {
    // var params = {"car_mileage": 1, "car_age": 2, "car_engine_hp": 3};
    // var url = Uri.https(authority)
    // var response = await http.get(Uri.parse("http://127.0.0.1:8000?"
    //     "car_mileage=${params['car_mileage']}&"
    //     "car_age=${params['car_age']}&"
    //     "car_engine_hp=${params['car_engine_hp']}"));

    setState(() {
      state = Constants.load_state;
    });

    double car_mileage = double.parse(_controller1.text);
    double car_age = double.parse(_controller2.text);
    double car_engine_hp = double.parse(_controller3.text);

    var response = await http.get(Uri.parse("${Constants.url}?"
        "car_mileage=$car_mileage"
        "&car_age=$car_age"
        "&car_engine_hp=$car_engine_hp"));

    setState(() {
      String priceRaw =
          (json.decode(response.body)['prediction'] as List)[0].toString();
      double price = double.parse(priceRaw);
      int priceTempVND = (double.parse(priceRaw) * 1401.07).round();

      var rubFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');
      priceRUB = rubFormat.format(price);

      var vndFormat = NumberFormat.currency(locale: 'vi_VN');
      priceVND = vndFormat.format(priceTempVND);

      state = Constants.watch_state;
    });
  }

  _buildResult(String state) {
    if (state == Constants.input_state) {
      return SizedBox(
        width: 40,
        height: 40,
        child: LoadingAnimationWidget.halfTriangleDot(
            color: Colors.black, size: 50),
      );
    } else if (state == Constants.load_state) {
      return SizedBox(
        width: 40,
        height: 40,
        child: LoadingAnimationWidget.halfTriangleDot(
            color: Colors.black, size: 50),
      );
    } else {
      return ResultPredict(priceRUB: priceRUB, priceVND: priceVND);
    }
  }
}

class ResultPredict extends StatelessWidget {
  const ResultPredict(
      {super.key, required this.priceRUB, required this.priceVND});

  final String priceRUB;
  final String priceVND;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool isWideDevice = constraints.maxWidth > 600;
          return Column(
            children: [
              Center(
                  child: Text(
                priceRUB,
                style: TextStyle(fontSize: isWideDevice ? 30 : 20),
              )),
              const SizedBox(height: 16.0),
              Center(
                  child: Text(
                priceVND,
                style: TextStyle(fontSize: isWideDevice ? 30 : 20),
              )),
            ],
          );
        },
      ),
    );
  }
}

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    super.key,
    required TextEditingController controller1,
    required this.field,
  }) : _controller1 = controller1;

  final TextEditingController _controller1;
  final String field;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool isWideDevice = constraints.maxWidth > 600;

        return SizedBox(
          width: 500,
          child: TextFormField(
            controller: _controller1,
            decoration: InputDecoration(
                labelText: field,
                labelStyle: TextStyle(fontSize: isWideDevice ? 25 : 18)),
            style: TextStyle(fontSize: isWideDevice ? 30 : 20),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              } else if (!isNumeric(value)) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }
}
