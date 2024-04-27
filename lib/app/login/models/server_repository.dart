import 'package:harvest/app/login/models/server.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ServerRepository {
  late Database _db;

  Future<Database?> get db async {
    _db = (await init())!;
    return _db;
  }

  Future<Database?> init() async {
    // 初始化数据库连接
    // if (Platform.isIOS || Platform.isAndroid) {
    //   var status = await Permission.storage.status;
    //   if (!status.isGranted) {
    //     // 用户未授予存储权限
    //     Map<Permission, PermissionStatus> permissions =
    //         await [Permission.storage].request();
    //     final storageStatus = permissions[Permission.storage]!;
    //     if (storageStatus.isGranted) {
    //       Logger.instance.i('权限已获取，现在可以访问存储');
    //     } else if (storageStatus.isPermanentlyDenied) {
    //       Logger.instance.i('用户永久拒绝了权限，可以提示用户去应用设置里手动开启');
    //       Get.snackbar(
    //         '无存储权限',
    //         '您拒绝了权限，请到应用设置里手动开启！',
    //         colorText: Colors.white,
    //         backgroundColor: Colors.red.shade300,
    //       );
    //     }
    //     Get.snackbar("Error", "无存储权限！");
    //     Get.snackbar(
    //       '无存储权限',
    //       '请手动到设置中开启存储权限！',
    //       colorText: Colors.white,
    //       backgroundColor: Colors.red.shade300,
    //     );
    //     return null;
    //   }
    // }
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'harvest.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
    return _db;
  }

  // 创建数据库表
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE servers (
        id INTEGER PRIMARY KEY,
        name TEXT,
        protocol TEXT,
        domain TEXT,
        port INTEGER,
        username TEXT,
        password TEXT,
        selected INTEGER DEFAULT 0,
        UNIQUE (protocol, domain, port)
      )
    ''');
  }

  // 数据库升级逻辑
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE servers
        ADD COLUMN username TEXT DEFAULT ''
      ''');
      await db.execute('''
        ALTER TABLE servers
        ADD COLUMN password TEXT DEFAULT NULL
      ''');
    }
  }

  // 插入新的服务器信息
  Future<int> insertServer(Server server) async {
    if (server.selected) {
      // 先将所有服务器的 selected 字段设置为 false
      await _db.update(
        'servers',
        {'selected': false},
        where: '1 = 1', // 更新所有记录
      );
    }
    return await _db.insert('servers', server.toJson()..remove('id'));
  }

  // 获取所有服务器信息
  Future<List<Server>> getServers() async {
    final List<Map<String, dynamic>> maps = await _db.query('servers');
    return List.generate(maps.length, (i) {
      return Server.fromJson(maps[i]);
    });
  }

// 更新服务器信息
  Future<void> updateServer(Server server) async {
    if (server.selected) {
      // 先将所有服务器的 selected 字段设置为 false
      await _db.update(
        'servers',
        {'selected': 0},
        where: '1 = 1', // 更新所有记录
      );
    }

    await _db.update(
      'servers',
      server.toJson(),
      where: 'id = ?',
      whereArgs: [server.id],
    );
  }

  // 删除服务器信息
  Future<void> deleteServer(int id) async {
    await _db.delete(
      'servers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 根据ID获取单个服务器信息
  Future<Server?> getServerById(int id) async {
    final List<Map<String, Object?>> maps = await _db.query(
      'servers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Server.fromJson(maps.first.cast<String, dynamic>());
    } else {
      return null;
    }
  }
}
