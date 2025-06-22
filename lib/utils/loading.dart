// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ScreenWithLoader extends StatefulWidget {
  final bool isLoading;
  Color color;
  final Widget? body;

  ScreenWithLoader({super.key, required this.isLoading, this.body, this.color = Colors.white38});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ScreenWithLoader> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: widget.body,
          ),
          Visibility(
            visible: widget.isLoading,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: widget.color,
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: new BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Loading...',
                        style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14)
                        
                      ),
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
