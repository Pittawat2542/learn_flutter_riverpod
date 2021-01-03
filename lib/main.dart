import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

void main() => runApp(ProviderScope(child: MyApp()));

final greetingProvider = Provider((ref) => 'Hello Riverpod!');

// [1]. First way to access to state is via extends ConsumerWidget instead of
// normal StatelessWidget and modify the build() method to have access on
// watch(). However, this method has some performance concern as it will
// rebuild the whole widget when the value that has watched change.

// class MyApp extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final greetingText = watch(greetingProvider);
//
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Learn Riverpod'),
//         ),
//         body: Center(
//           child: Text(greetingText),
//         ),
//       ),
//     );
//   }
// }

// [2]. Second way to access state is to use Consumer widget which is more scoped.

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Learn Riverpod'),
//         ),
//         body: Consumer(
//           builder: (context, watch, child) {
//             final greetingText = watch(greetingProvider);
//
//             return Text(greetingText);
//           },
//         ),
//       ),
//     );
//   }
// }

// [3]. In the case of needing to read value only one time, use context.read()

class IncrementNotifier extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  void increment() {
    _value++;
    notifyListeners();
  }
}

final incrementProvider = ChangeNotifierProvider((ref) => IncrementNotifier());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Learn Riverpod'),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Center(
//               child: Consumer(
//                 builder: (context, watch, child) {
//                   final greetingText = watch(greetingProvider);
//
//                   return Text(greetingText);
//                 },
//               ),
//             ),
//             Center(
//               child: Consumer(
//                 builder: (context, watch, child) {
//                   final incrementNotifier = watch(incrementProvider);
//
//                   return Text(incrementNotifier.value.toString());
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             final provider = context.read<IncrementNotifier>(incrementProvider);
//
//             provider.increment();
//           },
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }

// [4]. To work with asynchronous job use futureProvider or streamProvider
// .family allow to pass input to the provider
// .autoDispose disable cache feature when no one watch

class FakeHttpClient {
  Future<String> get(String url) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Response from $url';
  }
}

final fakeHttpClientProvider = Provider((ref) => FakeHttpClient());
final responseProvider =
    FutureProvider.autoDispose.family<String, String>((ref, url) async {
  final httpClient = ref.read(fakeHttpClientProvider);
  return httpClient.get(url);
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Learn Riverpod'),
        ),
        body: Center(
          child: Consumer(
            builder: (context, watch, child) {
              final responseAsyncValue =
                  watch(responseProvider('https://example.com'));

              return responseAsyncValue.map(
                data: (_) => Text(_.value),
                loading: (_) => const CircularProgressIndicator(),
                error: (_) => Text(
                  _.error.toString(),
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
