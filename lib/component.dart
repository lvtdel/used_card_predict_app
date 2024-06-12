import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

class ResultPredict extends StatelessWidget {
  const ResultPredict(
      {super.key,
      required this.priceRUB,
      required this.priceVND,
      required this.priceUSD});

  final String priceRUB;
  final String priceVND;
  final String priceUSD;

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
                priceVND,
                style: TextStyle(fontSize: isWideDevice ? 30 : 20),
              )),
              const SizedBox(height: 16.0),
              Center(
                  child: Text(
                priceRUB,
                style: TextStyle(fontSize: isWideDevice ? 30 : 20),
              )),
              const SizedBox(height: 16.0),
              Center(
                  child: Text(
                priceUSD,
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

class MyDropdownButton extends StatefulWidget {
  MyDropdownButton(
      {super.key, required this.selectedItem, required this.onSelectChange, required this.items});

  final onSelectChange;
  String selectedItem = 'Toyota';
  List<String> items = ['Toyota'];

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool isWideDevice = constraints.maxWidth > 600;
      return SizedBox(
        width: 500,
        child: DropdownButton<String>(
          value: widget.selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              // widget.selectedItem = newValue ?? "NULL";
              widget.onSelectChange(newValue);
            });
          },
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: TextStyle(fontSize: isWideDevice ? 25 : 15)),
            );
          }).toList(),
          hint: Center(
              child: Text(
            'Select the aniaml you love',
            style: TextStyle(
                fontSize: isWideDevice ? 25 : 15, color: Colors.white),
          )),
        ),
      );
    });
  }


}