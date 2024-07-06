import 'package:flutter/material.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyButton(
            method: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
            text: 'For Help',
            color: Color.fromARGB(255, 185, 178, 224),
          ),
          SizedBox(
            height: 30,
          ),
          MyButton(
            method: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQPage()),
              );
            },
            text: 'FAQS',
            color: Color.fromARGB(255, 185, 178, 224),
          ),
          SizedBox(
            height: 30,
          ),
          MyButton(
            method: () async {
              await api.logOut(context);
            },
            text: 'logout',
            color: Color.fromARGB(255, 237, 137, 126),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is IoT and why is it growing in interest?',
      'answer':
          'IoT (Internet of Things) is a network of physical devices that communicate and exchange data. It is growing in interest due to its potential to revolutionize various industries by providing smarter solutions and automation.'
    },
    {
      'question': 'What are the barriers to entry for beginners in IoT?',
      'answer':
          'The main barriers include the complexity of hardware control and the need for programming expertise. Beginners often find it challenging to get started with IoT development due to these technical requirements.'
    },
    {
      'question': 'How can user-friendly hardware control solutions help?',
      'answer':
          'User-friendly hardware control solutions simplify the process, making it accessible for individuals without technical backgrounds to create and manage IoT projects effectively.'
    },
    {
      'question': 'Why use ESP32 microcontrollers for IoT projects?',
      'answer':
          'ESP32 microcontrollers are affordable, versatile, and open-source, making them ideal for a wide range of IoT applications. They offer robust performance and are supported by a large community of developers.'
    },
    {
      'question': 'Can I interact with ESP32 without programming expertise?',
      'answer':
          'Yes, our mobile app and installer are designed to facilitate intuitive interaction with ESP32 microcontrollers without requiring any programming knowledge.'
    },
    {
      'question': 'How do AWS and Gemini assist in hardware code generation?',
      'answer':
          'AWS and Gemini can generate hardware code through simple prompts, eliminating the need for manual coding and reducing the likelihood of errors in code generation.'
    },
    {
      'question': 'What are the key benefits of this approach?',
      'answer':
          'This approach democratizes IoT development, fosters STEM education, empowers community-driven innovation, and accelerates prototyping for startups, enabling rapid testing and refinement of IoT concepts.'
    },
  ];

  FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ - IoT App'),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faqs[index]['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _issueController = TextEditingController();

  void _submitIssue() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Issue Submitted'),
            content: Text(
                'Thank you for submitting your issue. We will get back to you shortly.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      _emailController.clear();
      _issueController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help - Submit an Issue'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _issueController,
                decoration: InputDecoration(
                  labelText: 'Describe your issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your issue';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitIssue,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
