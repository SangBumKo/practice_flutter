import 'package:flutter/material.dart';

class SecondJoin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('이메일 인증', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        //actions?
        actions: <Widget>[
          TextButton(
            onPressed: (){},
            child: Text('다음', style: TextStyle(fontSize: 17.5),),
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
                child: Theme(
                  data: ThemeData(
                      inputDecorationTheme: const InputDecorationTheme(
                          labelStyle: TextStyle(
                            color: Colors.black,
                          )
                      )
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      labelText: '이메일'
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              OutlinedButton(
                                child: Text('인증'),
                                onPressed: (){},
                                style: OutlinedButton.styleFrom(
                                    primary: Colors.green,
                                    minimumSize: Size(70, 40),
                                    side: BorderSide(
                                      color: Colors.green,
                                      width: 1.0,
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){},
                          child: Text('회원가입완료'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}