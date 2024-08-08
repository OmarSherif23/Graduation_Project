import 'package:Chatty/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  required Function function,
  bool upper = true,
  required String text,
}) => Container(
  width: width,
  height: 40.0,
  color: background,
  child: MaterialButton(
    onPressed: (){
      function();
    },
    child: Text(
      upper ? text.toUpperCase() : text,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  ),
);


Widget defaultTextForm({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onChange,
  Function? suffixPressed,
  required String? Function(String? val)? validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool ispassword = false,
}) => TextFormField(
  controller: controller,
  keyboardType: type,
  obscureText: ispassword,
  onFieldSubmitted: onSubmit != null? onSubmit() : null,
  onChanged: onChange != null? onChange() : null,
  validator: validate,
  decoration: InputDecoration(
    prefixIcon: Icon(
      prefix,
    ),
    suffixIcon: suffix !=null ?
    IconButton(
        onPressed:(){
          suffixPressed!();
        } ,
        icon: Icon(suffix,)) : null,
    labelText: label,
    border: const OutlineInputBorder(),
  ),
);


Widget defaultTextButton({
  required Function function,
  required String text,
}) =>
    TextButton(
    onPressed: (){
      function();
    },
    child: Text(text.toUpperCase()),
    );

void navigateTo(context,widget) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context)=> widget,
      ),
);

void navigateAndfFinish(context,widget
    ) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) => widget,
    ),
    (route)
    {
      return false;
    },
);


void showToast({
  required String text,
  required ToastStates state,
    }) =>
    Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: Colors.black,
    textColor: chooseToastColor(state),
    fontSize: 16.0,
);

enum ToastStates {SUCCESS,ERROR,WARNING}

Color chooseToastColor(ToastStates state)
{
  switch(state)
  {
    case ToastStates.SUCCESS:
      return Colors.green;
    case ToastStates.ERROR:
      return Colors.red;
    case ToastStates.WARNING:
      return Colors.white;
  }
}
PreferredSizeWidget? defaultAppBar({
  required BuildContext context,
  String? title,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
      onPressed: ()
      {
        Navigator.pop(context);
      },
      icon: const Icon(
          IconBroken.Arrow___Left_2,
      ),
  ),
  titleSpacing: 5.0,
  title: Text(
    title!,
  ),
  actions: actions,
);

Widget myDivider() => Container(
  width: double.infinity,
  height: 1.0,
  color: Colors.grey[300],
);