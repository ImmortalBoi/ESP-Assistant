import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/chat_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    _model = GenerativeModel(
        model: "gemini-pro", apiKey: 'AIzaSyBkJjJY5ncrmvKdsm2DhNUNDAkjOUAkEqA');
    _chat = _model.startChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Chat with Gemini"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, idx) {
                  final content = _chat.history.toList()[idx];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map<String>((e) => e.text)
                      .join('');
                  return MessageWidget(
                    text: text,
                    isFromUser: content.role == 'user',
                  );
                },
                itemCount: _chat.history.length,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          hintText: 'Enter a prompt...',
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(14),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(14),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (String value) {
                          _sendChatMessage(value);
                        },
                      ),
                    ),
                    const SizedBox.square(
                      dimension: 15,
                    ),
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          _sendChatMessage(_textController.text);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() => _loading = true);

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null) {
        debugPrint('No response from API.');
        return;
      }
      setState(() => _loading = false);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _textController.clear();
      setState(() => _loading = false);
    }
  }
}
