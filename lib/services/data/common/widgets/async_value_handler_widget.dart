import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base loading and error widgets
class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _DefaultError extends StatelessWidget {
  const _DefaultError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) => Center(child: Text(error.toString()));
}

/// Single value
class AsyncValueHandlerWidget<T> extends StatelessWidget {
  const AsyncValueHandlerWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? () => const _DefaultLoading(),
      error: error ?? (e, st) => _DefaultError(e, st),
    );
  }
}

/// Two values
class AsyncValueHandlerWidget2<T1, T2> extends StatelessWidget {
  const AsyncValueHandlerWidget2({
    required this.value1,
    required this.value2,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T1> value1;
  final AsyncValue<T2> value2;
  final Widget Function(T1, T2) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;

  @override
  Widget build(BuildContext context) {
    return value1.when(
      data: (data1) => value2.when(
        data: (data2) => data(data1, data2),
        loading: loading ?? () => const _DefaultLoading(),
        error: error ?? (e, st) => _DefaultError(e, st),
      ),
      loading: loading ?? () => const _DefaultLoading(),
      error: error ?? (e, st) => _DefaultError(e, st),
    );
  }
}

/// Three values
class AsyncValueHandlerWidget3<T1, T2, T3> extends StatelessWidget {
  const AsyncValueHandlerWidget3({
    required this.value1,
    required this.value2,
    required this.value3,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T1> value1;
  final AsyncValue<T2> value2;
  final AsyncValue<T3> value3;
  final Widget Function(T1, T2, T3) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;

  @override
  Widget build(BuildContext context) {
    return value1.when(
      data: (data1) => value2.when(
        data: (data2) => value3.when(
          data: (data3) => data(data1, data2, data3),
          loading: loading ?? () => const _DefaultLoading(),
          error: error ?? (e, st) => _DefaultError(e, st),
        ),
        loading: loading ?? () => const _DefaultLoading(),
        error: error ?? (e, st) => _DefaultError(e, st),
      ),
      loading: loading ?? () => const _DefaultLoading(),
      error: error ?? (e, st) => _DefaultError(e, st),
    );
  }
}

/// Four values
class AsyncValueHandlerWidget4<T1, T2, T3, T4> extends StatelessWidget {
  const AsyncValueHandlerWidget4({
    required this.value1,
    required this.value2,
    required this.value3,
    required this.value4,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T1> value1;
  final AsyncValue<T2> value2;
  final AsyncValue<T3> value3;
  final AsyncValue<T4> value4;
  final Widget Function(T1, T2, T3, T4) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;

  @override
  Widget build(BuildContext context) {
    return value1.when(
      data: (data1) => value2.when(
        data: (data2) => value3.when(
          data: (data3) => value4.when(
            data: (data4) => data(data1, data2, data3, data4),
            loading: loading ?? () => const _DefaultLoading(),
            error: error ?? (e, st) => _DefaultError(e, st),
          ),
          loading: loading ?? () => const _DefaultLoading(),
          error: error ?? (e, st) => _DefaultError(e, st),
        ),
        loading: loading ?? () => const _DefaultLoading(),
        error: error ?? (e, st) => _DefaultError(e, st),
      ),
      loading: loading ?? () => const _DefaultLoading(),
      error: error ?? (e, st) => _DefaultError(e, st),
    );
  }
}

/// Five values
class AsyncValueHandlerWidget5<T1, T2, T3, T4, T5> extends StatelessWidget {
  const AsyncValueHandlerWidget5({
    required this.value1,
    required this.value2,
    required this.value3,
    required this.value4,
    required this.value5,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T1> value1;
  final AsyncValue<T2> value2;
  final AsyncValue<T3> value3;
  final AsyncValue<T4> value4;
  final AsyncValue<T5> value5;
  final Widget Function(T1, T2, T3, T4, T5) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace?)? error;

  @override
  Widget build(BuildContext context) {
    return value1.when(
      data: (data1) => value2.when(
        data: (data2) => value3.when(
          data: (data3) => value4.when(
            data: (data4) => value5.when(
              data: (data5) => data(data1, data2, data3, data4, data5),
              loading: loading ?? () => const _DefaultLoading(),
              error: error ?? (e, st) => _DefaultError(e, st),
            ),
            loading: loading ?? () => const _DefaultLoading(),
            error: error ?? (e, st) => _DefaultError(e, st),
          ),
          loading: loading ?? () => const _DefaultLoading(),
          error: error ?? (e, st) => _DefaultError(e, st),
        ),
        loading: loading ?? () => const _DefaultLoading(),
        error: error ?? (e, st) => _DefaultError(e, st),
      ),
      loading: loading ?? () => const _DefaultLoading(),
      error: error ?? (e, st) => _DefaultError(e, st),
    );
  }
}
