import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: MyComponent(),
        ),
      ),
    );
  }
}

class MyComponent extends StatelessWidget {
  const MyComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF1F1EF),
      padding: EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 59),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.network(
                        'https://cdn.builder.io/api/v1/image/assets/TEMP/8ba87256-f5c1-4499-95be-87d921f82f92?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                        fit: BoxFit.contain,
                      ),
                      Container(
                        child: Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
              Image.network(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/dce8773d-fe37-4179-aab0-4601f14f8d12?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                fit: BoxFit.contain,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 93),
            child: Text('Sign Up'),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFFC7DAD4), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/7f37c184-66c9-4434-9afc-a2e67356415e?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                  fit: BoxFit.contain,
                ),
                Container(
                  child: Text('Full Name'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFFC7DAD4), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/4cddd89d-e0b8-41a3-ad8a-1556ccc06c03?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                  fit: BoxFit.contain,
                ),
                Container(
                  child: Text('Email'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFFC7DAD4), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/7ade19aa-ac75-4417-91d5-bf87d3ceab8d?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                      fit: BoxFit.contain,
                    ),
                    Container(
                      child: Text('Password'),
                    ),
                  ],
                ),
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/4d365d6a-2121-480f-982f-f58808766161?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFFC7DAD4), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/18ee22dc-3c4b-4b1d-b66c-d4bfaeb9b08b?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                      fit: BoxFit.contain,
                    ),
                    Container(
                      child: Text('Confirm Password'),
                    ),
                  ],
                ),
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/bb8987ef-9717-4aa4-be7a-5d09905738fc?apiKey=dae3db0c5c3b449aa158c0c3980008ca&',
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFF3894A3),
            ),
            child: Text('Sign Up'),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text('Already have an account ?'),
                Text('Sign In'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
