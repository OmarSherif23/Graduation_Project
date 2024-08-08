import 'package:Chatty/models/social_app/social_user_model.dart';



String? loggedID = '';
String? messageImg;
bool isWarning = false;
String? url1;
SocialUserModel socialUserModel = SocialUserModel();
// bool isImage = false;


enum MessageType{
  text,
  image,
  voice
}