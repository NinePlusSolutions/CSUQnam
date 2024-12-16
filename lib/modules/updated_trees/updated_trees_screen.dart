import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/modules/home/home_controller.dart';
import 'package:intl/intl.dart'; // Add this import

// ignore: use_key_in_widget_constructors
class UpdatedTreesScreen extends StatelessWidget {
  final HomeController controller = Get.find();
  final selectedItems = <String>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách cây cao su'),
      ),
      body: Obx(() {
        if (controller.updatedTrees.isEmpty) {
          return const Center(
            child: Text('Không có thông tin nào'),
          );
        }
        return Column(
          children: [
            if (controller.updatedTrees.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Select all logic
                        selectedItems.addAll(controller.updatedTrees);
                      },
                      child: const Text('Select All'),
                    ),
                    if (selectedItems.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          // Delete logic
                          controller.updatedTrees.removeAll(selectedItems);
                          for (var treeId in selectedItems) {
                            controller.updatedTrees.remove(treeId);
                          }
                          selectedItems.clear();
                          controller.updatedTreesCount.value =
                              controller.updatedTrees.length;
                          controller.storage.write(
                              'updatedTrees', controller.updatedTrees.toList());
                          controller.storage.write('updatedTreesCount',
                              controller.updatedTreesCount.value);
                        },
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (selectedItems.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          // Sync logic
                          selectedItems.clear();
                        },
                        child: const Text('Đồng bộ'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.updatedTrees.length,
                itemBuilder: (context, index) {
                  final treeId = controller.updatedTrees.elementAt(index);
                  return Slidable(
                    key: ValueKey(treeId),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(onDismissed: () {}),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            // Delete logic
                            controller.updatedTrees.remove(treeId);
                            controller.updatedTreesCount.value =
                                controller.updatedTrees.length;
                            controller.storage.write('updatedTrees',
                                controller.updatedTrees.toList());
                            controller.storage.write('updatedTreesCount',
                                controller.updatedTreesCount.value);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            // Share logic
                          },
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.share,
                          label: 'Share',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (context) {
                            // Archive logic
                          },
                          backgroundColor: const Color(0xFF7BC043),
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                          label: 'Archive',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            // Save logic
                          },
                          backgroundColor: const Color(0xFF0392CF),
                          foregroundColor: Colors.white,
                          icon: Icons.save,
                          label: 'Save',
                        ),
                      ],
                    ),
                    child: Obx(() => CheckboxListTile(
                          title: Text(treeId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.green),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Tên nông trường: ${controller.getUpdatedTreeDetails(treeId)['farm']}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.landscape,
                                        color: Colors.brown),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Lô: ${controller.getUpdatedTreeDetails(treeId)['lot']}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.format_list_numbered,
                                        color: Colors.blue),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Hàng: ${controller.getUpdatedTreeDetails(treeId)['row']}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.orange),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Trạng thái: ${controller.getUpdatedTreeDetails(treeId)['status']}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.description,
                                        color: Colors.purple),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Mô tả: ${controller.getUpdatedTreeDetails(treeId)['description']}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.update, color: Colors.red),
                                    const SizedBox(width: 5),
                                    Text(
                                        'Ngày giờ updated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(controller.getUpdatedTreeDetails(treeId)['updatedTime']!))}',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          value: selectedItems.contains(treeId),
                          onChanged: (bool? value) {
                            if (value == true) {
                              selectedItems.add(treeId);
                            } else {
                              selectedItems.remove(treeId);
                            }
                          },
                        )),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
