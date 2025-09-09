import 'package:flutter/material.dart';

enum MenuItem {
  editInfo,
  deviceList,
  deviceInformation,
  messages,
  rtus,
  relaies,
  irrigation
}

const menuItemIcon = {
  MenuItem.editInfo: Icons.edit_rounded,
  MenuItem.deviceList: Icons.list_rounded,
  MenuItem.messages: Icons.message_rounded,
  MenuItem.deviceInformation: Icons.perm_device_info_rounded,
  MenuItem.rtus: Icons.auto_awesome_mosaic_rounded,
  MenuItem.relaies: Icons.lightbulb_circle_rounded,
  MenuItem.irrigation: Icons.edit_calendar_rounded,
};
const menuItemName = {
  MenuItem.editInfo: 'ویرایش اطلاعات کاربری',
  MenuItem.deviceList: 'لیست دستگاه ها',
  MenuItem.messages: 'پیام ها',
  MenuItem.deviceInformation: 'اطلاعات دستگاه',
  MenuItem.rtus: 'کنترل واحد ها',
  MenuItem.relaies: 'منابع و مخازن',
  MenuItem.irrigation: 'آبیاری',
};

class menu {
  const menu({
    required this.menuItem,
  });

  final MenuItem menuItem;
}
