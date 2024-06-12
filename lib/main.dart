import 'dart:async';
import 'dart:convert';

import 'package:car_used_price_predict/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'component.dart';

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
  final TextEditingController _controller4 = TextEditingController();
  Timer? _timer;
  String priceRUB = "";
  String priceVND = "";
  String priceUSD = "";
  String state = Constants.input_state;

  String selectedBrand = "Toyota";
  List<String> brandList = ['Toyota'];
  String selectedModel = "Toyota";
  List<String> modelList = ['Toyota'];
  bool _callSubmit = false;

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
                  MyDropdownButton(
                    selectedItem: selectedBrand,
                    onSelectChange: _onBrandChange,
                    items: brandList,
                  ),
                  const SizedBox(height: 16.0),
                  MyDropdownButton(
                    selectedItem: selectedModel,
                    onSelectChange: _onModelChange,
                    items: modelList,
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(
                      controller1: _controller1, field: 'Car mileage (Km)'),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(
                      controller1: _controller2, field: 'Car age (Year)'),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(
                      controller1: _controller3,
                      field: 'Car engine capacity (L)'),
                  const SizedBox(height: 16.0),
                  TextFieldCustom(
                      controller1: _controller4, field: 'Car engine hp (HP)'),
                  const SizedBox(height: 16.0),
                  _buildResult(state)
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
    _controller4.removeListener(_onTextChanged);
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _fetchBrands();

    _controller4.addListener(_addTextListener);
  }

  _addTextListener() {
    _callSubmit = true;
    _controller1.addListener(_onTextChanged);
    _controller2.addListener(_onTextChanged);
    _controller3.addListener(_onTextChanged);
    _controller4.addListener(_onTextChanged);

    _controller4.removeListener(_addTextListener);
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
    setState(() {
      state = Constants.load_state;
    });

    double car_mileage = double.parse(_controller1.text);
    double car_age = double.parse(_controller2.text);
    double car_engine_capacity = double.parse(_controller3.text);
    double car_engine_hp = double.parse(_controller4.text);
    String car_brand = selectedBrand;
    String car_model = selectedModel;

    var response = await http.get(Uri.parse(BuildUrl.buil_url_predict(
        car_mileage, car_age, car_engine_hp, car_brand, car_model)));

    String priceRaw =
        (json.decode(response.body)['prediction'] as List)[0].toString();
    double price = double.parse(priceRaw);
    int priceTempVND = (double.parse(priceRaw) * 284.97).round();
    int priceTempUSD = (double.parse(priceRaw) * 0.011).round();

    setState(() {
      var rubFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');
      priceRUB = rubFormat.format(price);

      var vndFormat = NumberFormat.currency(locale: 'vi_VN');
      priceVND = vndFormat.format(priceTempVND);

      var usdFormat = NumberFormat.currency(locale: 'en_US', symbol: "\$");
      priceUSD = usdFormat.format(priceTempUSD);

      state = Constants.watch_state;
    });
  }

  _onBrandChange(newValue) {
    if (newValue != null) {
      setState(() {
        this.selectedBrand = newValue;
      });
      _fetchModels(newValue);
    }
  }

  _onModelChange(newValue) {
    if (newValue != null) {
      setState(() {
        selectedModel = newValue ?? "Toyota";
      });

      if (_callSubmit) {
        _submit();
        print("submit");
      }
    }
  }

  _fetchModels(String brand) async {
    var response = await http
        .get(Uri.parse(BuildUrl.build_url_get_models_by_brand(brand)));

    setState(() {
      modelList = List<String>.from(json.decode(response.body)['models']);
      selectedModel = modelList.first;
      // print(modelList);
      // print(selectedModel);
    });
  }

  _fetchBrands() async {
    var response = await http.get(Uri.parse(Constants.url_get_brands));

    setState(() {
      brandList = List<String>.from(json.decode(response.body)['brands']);
      selectedBrand = brandList.first;
    });

    _fetchModels(selectedBrand);
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
      return ResultPredict(
          priceRUB: priceRUB, priceVND: priceVND, priceUSD: priceUSD);
    }
  }
}
