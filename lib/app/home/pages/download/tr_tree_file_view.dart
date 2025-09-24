import 'package:flutter/material.dart';

import '../../../../common/card_view.dart';
import '../../../../utils/string_utils.dart';
import '../models/transmission_base_torrent.dart';

class TreeNode {
  String name;
  Map<String, TreeNode> children;
  TorrentFile? content;

  TreeNode(this.name)
      : children = {},
        content = null;

  @override
  String toString() => name;
}

class TransmissionTreeView extends StatelessWidget {
  final List<TorrentFile> contents;

  const TransmissionTreeView(this.contents, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TreeNode> nodes = generateTreeNodes(contents);
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        TreeNode node = nodes[index];
        return _buildTreeTile(node, 0);
      },
    );
  }

  List<TreeNode> generateTreeNodes(List<TorrentFile> contents) {
    Map<String, TreeNode> nodesMap = {};

    for (TorrentFile content in contents) {
      List<String> filePathParts = content.name.split('/');
      TreeNode currentNode = nodesMap.putIfAbsent(filePathParts.first, () => TreeNode(filePathParts.first));
      for (int i = 1; i < filePathParts.length; i++) {
        String part = filePathParts[i];
        if (currentNode.children.containsKey(part)) {
          currentNode = currentNode.children[part]!;
        } else {
          TreeNode newNode = TreeNode(part);
          currentNode.children[part] = newNode;
          currentNode = newNode;
        }
      }
      if (currentNode.children.isEmpty) {
        currentNode.content = content; // 只有叶子节点才赋值 content
      }
    }

    return nodesMap.values.toList();
  }

  Widget _buildTreeTile(TreeNode node, int level) {
    EdgeInsetsGeometry padding = EdgeInsets.only(left: level * 16.0);
    if (node.content != null) {
      return ListTile(
        // contentPadding: padding,
        leading: const Icon(Icons.file_copy_sharp),
        dense: true,
        title: Text(
          node.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextTag(
              labelText: FileSizeConvert.parseToFileSize(node.content!.length),
              icon: const Icon(Icons.download_done, size: 10, color: Colors.white),
            ),
            CustomTextTag(
                icon: const Icon(Icons.download_outlined, size: 10, color: Colors.white),
                labelText: (node.content!.bytesCompleted / node.content!.length).toStringAsFixed(2)),
          ],
        ),
        // 添加其他内容字段
      );
    }
    return ExpansionTile(
      childrenPadding: padding,
      dense: true,
      leading: const Icon(
        Icons.folder,
        color: Colors.deepOrangeAccent,
      ),
      key: PageStorageKey<String>(node.name),
      title: Text(
        node.name,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        ...node.children.values.map((child) => _buildTreeTile(child, level + 1)),
      ],
    );
  }
}
