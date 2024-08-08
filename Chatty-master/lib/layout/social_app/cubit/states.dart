
abstract class SocialStates {}

class SocialInitialState extends SocialStates {}
class SocialGetUserSuccessState extends SocialStates {}
class SocialGetUserLoadingState extends SocialStates {}
class SocialGetUserErrorState extends SocialStates
{
  final String error;
  SocialGetUserErrorState(this.error);
}
class SocialChangeBottomNavState extends SocialStates {}

class SocialProfilePickedImageSuccessState extends SocialStates {}
class SocialProfilePickedImageErrorState extends SocialStates {}
class SocialCoverPickedImageSuccessState extends SocialStates {}
class SocialCoverPickedImageErrorState extends SocialStates {}
class SocialMessagePickedImageSuccessState extends SocialStates {}
class SocialMessagePickedImageErrorState extends SocialStates {}


class SocialUploadProfileImageSuccessState extends SocialStates {}
class SocialUploadProfileImageErrorState extends SocialStates {}

class SocialUploadMessageImageSuccessState extends SocialStates {}
class SocialUploadMessageImageErrorState extends SocialStates {}

class SocialUploadCoverImageSuccessState extends SocialStates {}
class SocialUploadCoverImageErrorState extends SocialStates {}

class SocialUserUpdateErrorState extends SocialStates {}
class SocialUserUpdateLoadingState extends SocialStates {}

class SocialGetAllUsersLoadingState extends SocialStates{}
class SocialGetAllUsersSuccessState extends SocialStates{}
class SocialGetAllUsersErrorState extends SocialStates
{
  final String error;
  SocialGetAllUsersErrorState(this.error);
}

class SocialSendMessageSuccessState extends SocialStates{}
class SocialSendMessageErrorState extends SocialStates{}
class SocialGetMessagesSuccessState extends SocialStates{}
  class SocialRecieveMessageSuccessState extends SocialStates{}
