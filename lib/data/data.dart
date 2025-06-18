class ArtefakData {
  final String title;
  final String year;
  final String description;
  final String imageUrl; // Satu properti untuk URL gambar

  const ArtefakData({
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor untuk membuat ArtefakData dari data Firestore
  factory ArtefakData.fromFirestore(Map<String, dynamic> data) {
    return ArtefakData(
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '', // Ambil URL gambar dari Firestore
    );
  }
}

class BatuanData {
  final String title;
  final String year;
  final String description;
  final String imageUrl;

  const BatuanData({
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor untuk membuat BatuanData dari data Firestore
  factory BatuanData.fromFirestore(Map<String, dynamic> data) {
    return BatuanData(
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class FosilData {
  final String title;
  final String year;
  final String description;
  final String imageUrl;

  const FosilData({
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor untuk membuat FosilData dari data Firestore
  factory FosilData.fromFirestore(Map<String, dynamic> data) {
    return FosilData(
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class MineralData {
  final String title;
  final String year;
  final String description;
  final String imageUrl;

  const MineralData({
    required this.title,
    required this.year,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor untuk membuat MineralData dari data Firestore
  factory MineralData.fromFirestore(Map<String, dynamic> data) {
    return MineralData(
      title: data['title'] ?? 'Tanpa Judul',
      year: data['year'] ?? 'Tahun Tidak Diketahui',
      description: data['description'] ?? 'Tidak ada deskripsi.',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

// //Artefak
// class ArtefakData {
//   const ArtefakData({
//     required this.id,
//     required this.category,
//     required this.title,
//     required this.image,
//     required this.description,
//     required this.year,
//   });

//   final String category;
//   final String id;
//   final String title;
//   final String image;
//   final String description;
//   final String year;
// }

// List<ArtefakData> artefakDataList = [
//   const ArtefakData(
//       id: 'a1',
//       year: '1905',
//       category: 'Artefak',
//       title: 'Tyrannosaurus',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae tempus quam pellentesque nec nam aliquam sem et tortor. Enim sit amet venenatis urna cursus eget. Sed arcu non odio euismod lacinia at quis. Ut pharetra sit amet aliquam id diam. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Ac orci phasellus egestas tellus rutrum tellus. Arcu non odio euismod lacinia at quis risus sed vulputate. Sollicitudin nibh sit amet commodo nulla facilisi nullam vehicula ipsum. Sollicitudin ac orci phasellus egestas tellus rutrum. Faucibus ornare suspendisse sed nisi lacus sed. Hendrerit dolor magna eget est lorem. Congue eu consequat ac felis donec.'),
//   const ArtefakData(
//       id: 'a2',
//       year: '1900',
//       category: 'Artefak',
//       title: 'Artefak 2',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Amet justo donec enim diam vulputate ut pharetra sit. Sed tempus urna et pharetra pharetra massa massa ultricies. Amet cursus sit amet dictum sit amet justo donec enim. A diam sollicitudin tempor id eu nisl nunc. Justo nec ultrices dui sapien eget mi. Sit amet mattis vulputate enim nulla. Aliquam sem et tortor consequat id porta. Tempor nec feugiat nisl pretium fusce id velit. Ac felis donec et odio pellentesque diam. Sagittis id consectetur purus ut faucibus pulvinar elementum integer. Phasellus faucibus scelerisque eleifend donec pretium vulputate sapien nec sagittis. Congue quisque egestas diam in. Duis ut diam quam nulla.'),
//   const ArtefakData(
//       id: 'a3',
//       year: '1909',
//       category: 'Artefak',
//       title: 'Artefak 3',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Diam sit amet nisl suscipit. Eros in cursus turpis massa tincidunt dui ut ornare lectus. Pretium vulputate sapien nec sagittis aliquam malesuada. Neque viverra justo nec ultrices dui sapien eget mi. Neque viverra justo nec ultrices dui sapien eget. Maecenas ultricies mi eget mauris pharetra. Nisl pretium fusce id velit. Pellentesque eu tincidunt tortor aliquam. Non tellus orci ac auctor augue mauris augue. Tincidunt tortor aliquam nulla facilisi cras fermentum odio eu feugiat. Posuere morbi leo urna molestie. Etiam tempor orci eu lobortis elementum nibh. Curabitur vitae nunc sed velit. Risus sed vulputate odio ut enim blandit volutpat maecenas volutpat. Tortor vitae purus faucibus ornare suspendisse. Accumsan tortor posuere ac ut consequat semper. Sed enim ut sem viverra aliquet eget sit amet tellus. Massa tincidunt nunc pulvinar sapien et.'),
//   const ArtefakData(
//       id: 'a4',
//       year: '1908',
//       category: 'Artefak',
//       title: 'Artefak 4',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Fames ac turpis egestas integer eget aliquet nibh. Hac habitasse platea dictumst quisque sagittis purus sit amet volutpat. Sem et tortor consequat id porta nibh venenatis cras. Augue eget arcu dictum varius duis at consectetur lorem donec. Nec dui nunc mattis enim ut tellus elementum. Porttitor leo a diam sollicitudin tempor. Fringilla urna porttitor rhoncus dolor purus non enim praesent. Euismod nisi porta lorem mollis. Accumsan sit amet nulla facilisi morbi tempus. Sed elementum tempus egestas sed sed. Nisi scelerisque eu ultrices vitae auctor eu augue. Egestas purus viverra accumsan in nisl nisi scelerisque. Ac turpis egestas integer eget aliquet nibh praesent. Vestibulum rhoncus est pellentesque elit. Ornare lectus sit amet est placerat in.'),
// ];

// //Batuan
// class BatuanData {
//   const BatuanData({
//     required this.id,
//     required this.category,
//     required this.title,
//     required this.image,
//     required this.description,
//     required this.year,
//   });

//   final String category;
//   final String id;
//   final String title;
//   final String image;
//   final String description;
//   final String year;
// }

// List<BatuanData> batuanDataList = [
//   const BatuanData(
//       id: 'a1',
//       year: '1905',
//       category: 'Batuan',
//       title: 'Tyrannosaurus',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae tempus quam pellentesque nec nam aliquam sem et tortor. Enim sit amet venenatis urna cursus eget. Sed arcu non odio euismod lacinia at quis. Ut pharetra sit amet aliquam id diam. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Ac orci phasellus egestas tellus rutrum tellus. Arcu non odio euismod lacinia at quis risus sed vulputate. Sollicitudin nibh sit amet commodo nulla facilisi nullam vehicula ipsum. Sollicitudin ac orci phasellus egestas tellus rutrum. Faucibus ornare suspendisse sed nisi lacus sed. Hendrerit dolor magna eget est lorem. Congue eu consequat ac felis donec.'),
//   const BatuanData(
//       id: 'a2',
//       year: '1900',
//       category: 'Batuan',
//       title: 'Batuan 2',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Amet justo donec enim diam vulputate ut pharetra sit. Sed tempus urna et pharetra pharetra massa massa ultricies. Amet cursus sit amet dictum sit amet justo donec enim. A diam sollicitudin tempor id eu nisl nunc. Justo nec ultrices dui sapien eget mi. Sit amet mattis vulputate enim nulla. Aliquam sem et tortor consequat id porta. Tempor nec feugiat nisl pretium fusce id velit. Ac felis donec et odio pellentesque diam. Sagittis id consectetur purus ut faucibus pulvinar elementum integer. Phasellus faucibus scelerisque eleifend donec pretium vulputate sapien nec sagittis. Congue quisque egestas diam in. Duis ut diam quam nulla.'),
//   const BatuanData(
//       id: 'a3',
//       year: '1909',
//       category: 'Batuan',
//       title: 'Batuan 3',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Diam sit amet nisl suscipit. Eros in cursus turpis massa tincidunt dui ut ornare lectus. Pretium vulputate sapien nec sagittis aliquam malesuada. Neque viverra justo nec ultrices dui sapien eget mi. Neque viverra justo nec ultrices dui sapien eget. Maecenas ultricies mi eget mauris pharetra. Nisl pretium fusce id velit. Pellentesque eu tincidunt tortor aliquam. Non tellus orci ac auctor augue mauris augue. Tincidunt tortor aliquam nulla facilisi cras fermentum odio eu feugiat. Posuere morbi leo urna molestie. Etiam tempor orci eu lobortis elementum nibh. Curabitur vitae nunc sed velit. Risus sed vulputate odio ut enim blandit volutpat maecenas volutpat. Tortor vitae purus faucibus ornare suspendisse. Accumsan tortor posuere ac ut consequat semper. Sed enim ut sem viverra aliquet eget sit amet tellus. Massa tincidunt nunc pulvinar sapien et.'),
//   const BatuanData(
//       id: 'a4',
//       year: '1908',
//       category: 'Batuan',
//       title: 'Batuan 4',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Fames ac turpis egestas integer eget aliquet nibh. Hac habitasse platea dictumst quisque sagittis purus sit amet volutpat. Sem et tortor consequat id porta nibh venenatis cras. Augue eget arcu dictum varius duis at consectetur lorem donec. Nec dui nunc mattis enim ut tellus elementum. Porttitor leo a diam sollicitudin tempor. Fringilla urna porttitor rhoncus dolor purus non enim praesent. Euismod nisi porta lorem mollis. Accumsan sit amet nulla facilisi morbi tempus. Sed elementum tempus egestas sed sed. Nisi scelerisque eu ultrices vitae auctor eu augue. Egestas purus viverra accumsan in nisl nisi scelerisque. Ac turpis egestas integer eget aliquet nibh praesent. Vestibulum rhoncus est pellentesque elit. Ornare lectus sit amet est placerat in.'),
// ];

// //Fosil
// class FosilData {
//   const FosilData({
//     required this.id,
//     required this.category,
//     required this.title,
//     required this.image,
//     required this.description,
//     required this.year,
//   });

//   final String category;
//   final String id;
//   final String title;
//   final String image;
//   final String description;
//   final String year;
// }

// List<FosilData> fosilDataList = [
//   const FosilData(
//       id: 'a1',
//       year: '1905',
//       category: 'Fosil',
//       title: 'Tyrannosaurus',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae tempus quam pellentesque nec nam aliquam sem et tortor. Enim sit amet venenatis urna cursus eget. Sed arcu non odio euismod lacinia at quis. Ut pharetra sit amet aliquam id diam. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Ac orci phasellus egestas tellus rutrum tellus. Arcu non odio euismod lacinia at quis risus sed vulputate. Sollicitudin nibh sit amet commodo nulla facilisi nullam vehicula ipsum. Sollicitudin ac orci phasellus egestas tellus rutrum. Faucibus ornare suspendisse sed nisi lacus sed. Hendrerit dolor magna eget est lorem. Congue eu consequat ac felis donec.'),
//   const FosilData(
//       id: 'a2',
//       year: '1900',
//       category: 'Fosil',
//       title: 'Fosil 2',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Amet justo donec enim diam vulputate ut pharetra sit. Sed tempus urna et pharetra pharetra massa massa ultricies. Amet cursus sit amet dictum sit amet justo donec enim. A diam sollicitudin tempor id eu nisl nunc. Justo nec ultrices dui sapien eget mi. Sit amet mattis vulputate enim nulla. Aliquam sem et tortor consequat id porta. Tempor nec feugiat nisl pretium fusce id velit. Ac felis donec et odio pellentesque diam. Sagittis id consectetur purus ut faucibus pulvinar elementum integer. Phasellus faucibus scelerisque eleifend donec pretium vulputate sapien nec sagittis. Congue quisque egestas diam in. Duis ut diam quam nulla.'),
//   const FosilData(
//       id: 'a3',
//       year: '1909',
//       category: 'Fosil',
//       title: 'Fosil 3',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Diam sit amet nisl suscipit. Eros in cursus turpis massa tincidunt dui ut ornare lectus. Pretium vulputate sapien nec sagittis aliquam malesuada. Neque viverra justo nec ultrices dui sapien eget mi. Neque viverra justo nec ultrices dui sapien eget. Maecenas ultricies mi eget mauris pharetra. Nisl pretium fusce id velit. Pellentesque eu tincidunt tortor aliquam. Non tellus orci ac auctor augue mauris augue. Tincidunt tortor aliquam nulla facilisi cras fermentum odio eu feugiat. Posuere morbi leo urna molestie. Etiam tempor orci eu lobortis elementum nibh. Curabitur vitae nunc sed velit. Risus sed vulputate odio ut enim blandit volutpat maecenas volutpat. Tortor vitae purus faucibus ornare suspendisse. Accumsan tortor posuere ac ut consequat semper. Sed enim ut sem viverra aliquet eget sit amet tellus. Massa tincidunt nunc pulvinar sapien et.'),
//   const FosilData(
//       id: 'a4',
//       year: '1908',
//       category: 'Fosil',
//       title: 'Fosil 4',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Fames ac turpis egestas integer eget aliquet nibh. Hac habitasse platea dictumst quisque sagittis purus sit amet volutpat. Sem et tortor consequat id porta nibh venenatis cras. Augue eget arcu dictum varius duis at consectetur lorem donec. Nec dui nunc mattis enim ut tellus elementum. Porttitor leo a diam sollicitudin tempor. Fringilla urna porttitor rhoncus dolor purus non enim praesent. Euismod nisi porta lorem mollis. Accumsan sit amet nulla facilisi morbi tempus. Sed elementum tempus egestas sed sed. Nisi scelerisque eu ultrices vitae auctor eu augue. Egestas purus viverra accumsan in nisl nisi scelerisque. Ac turpis egestas integer eget aliquet nibh praesent. Vestibulum rhoncus est pellentesque elit. Ornare lectus sit amet est placerat in.'),
// ];

// //Mineral
// class MineralData {
//   const MineralData({
//     required this.id,
//     required this.category,
//     required this.title,
//     required this.image,
//     required this.description,
//     required this.year,
//   });

//   final String category;
//   final String id;
//   final String title;
//   final String image;
//   final String description;
//   final String year;
// }

// List<MineralData> mineralDataList = [
//   const MineralData(
//       id: 'a1',
//       year: '1905',
//       category: 'Mineral',
//       title: 'Tyrannosaurus',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae tempus quam pellentesque nec nam aliquam sem et tortor. Enim sit amet venenatis urna cursus eget. Sed arcu non odio euismod lacinia at quis. Ut pharetra sit amet aliquam id diam. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Ac orci phasellus egestas tellus rutrum tellus. Arcu non odio euismod lacinia at quis risus sed vulputate. Sollicitudin nibh sit amet commodo nulla facilisi nullam vehicula ipsum. Sollicitudin ac orci phasellus egestas tellus rutrum. Faucibus ornare suspendisse sed nisi lacus sed. Hendrerit dolor magna eget est lorem. Congue eu consequat ac felis donec.'),
//   const MineralData(
//       id: 'a2',
//       year: '1900',
//       category: 'Mineral',
//       title: 'Mineral 2',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Amet justo donec enim diam vulputate ut pharetra sit. Sed tempus urna et pharetra pharetra massa massa ultricies. Amet cursus sit amet dictum sit amet justo donec enim. A diam sollicitudin tempor id eu nisl nunc. Justo nec ultrices dui sapien eget mi. Sit amet mattis vulputate enim nulla. Aliquam sem et tortor consequat id porta. Tempor nec feugiat nisl pretium fusce id velit. Ac felis donec et odio pellentesque diam. Sagittis id consectetur purus ut faucibus pulvinar elementum integer. Phasellus faucibus scelerisque eleifend donec pretium vulputate sapien nec sagittis. Congue quisque egestas diam in. Duis ut diam quam nulla.'),
//   const MineralData(
//       id: 'a3',
//       year: '1909',
//       category: 'AMineral',
//       title: 'Mineral 3',
//       image: 'assets/image/trex.jpg',
//       description:
//           'Diam sit amet nisl suscipit. Eros in cursus turpis massa tincidunt dui ut ornare lectus. Pretium vulputate sapien nec sagittis aliquam malesuada. Neque viverra justo nec ultrices dui sapien eget mi. Neque viverra justo nec ultrices dui sapien eget. Maecenas ultricies mi eget mauris pharetra. Nisl pretium fusce id velit. Pellentesque eu tincidunt tortor aliquam. Non tellus orci ac auctor augue mauris augue. Tincidunt tortor aliquam nulla facilisi cras fermentum odio eu feugiat. Posuere morbi leo urna molestie. Etiam tempor orci eu lobortis elementum nibh. Curabitur vitae nunc sed velit. Risus sed vulputate odio ut enim blandit volutpat maecenas volutpat. Tortor vitae purus faucibus ornare suspendisse. Accumsan tortor posuere ac ut consequat semper. Sed enim ut sem viverra aliquet eget sit amet tellus. Massa tincidunt nunc pulvinar sapien et.'),
//   const MineralData(
//       id: 'a4',
//       year: '1908',
//       category: 'Mineral',
//       title: 'Mineral 4',
//       image: 'assets/image/museumgambar.jpg',
//       description:
//           'Fames ac turpis egestas integer eget aliquet nibh. Hac habitasse platea dictumst quisque sagittis purus sit amet volutpat. Sem et tortor consequat id porta nibh venenatis cras. Augue eget arcu dictum varius duis at consectetur lorem donec. Nec dui nunc mattis enim ut tellus elementum. Porttitor leo a diam sollicitudin tempor. Fringilla urna porttitor rhoncus dolor purus non enim praesent. Euismod nisi porta lorem mollis. Accumsan sit amet nulla facilisi morbi tempus. Sed elementum tempus egestas sed sed. Nisi scelerisque eu ultrices vitae auctor eu augue. Egestas purus viverra accumsan in nisl nisi scelerisque. Ac turpis egestas integer eget aliquet nibh praesent. Vestibulum rhoncus est pellentesque elit. Ornare lectus sit amet est placerat in.'),
// ];

// //193040044
// //rayhan abduhuda
