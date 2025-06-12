import '../Models/message_model.dart';

Map<String, List<ChatMessage>> mockChats = {
  'Pizza Palace': [
    ChatMessage(text: "Hi, is your pizza halal?", isUser: true, time: DateTime.now().subtract(Duration(minutes: 5))),
    ChatMessage(text: "Yes! All our ingredients are halal-certified.", isUser: false, time: DateTime.now().subtract(Duration(minutes: 3))),
  ],
  'Burger Haven': [
    ChatMessage(text: "Do you have vegetarian options?", isUser: true, time: DateTime.now().subtract(Duration(minutes: 10))),
    ChatMessage(text: "Yes, we have veggie burgers and salads!", isUser: false, time: DateTime.now().subtract(Duration(minutes: 9))),
  ],
};
