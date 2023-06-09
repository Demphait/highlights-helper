import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:single_house/db/streams_db.dart';
import 'package:single_house/models/highlight_model.dart';
import 'package:single_house/models/stream_model.dart';

part 'stream_state.dart';

class StreamCubit extends Cubit<StreamState> {
  StreamCubit() : super(StreamState());

  Future<void> loadingStreams() async {
    final streams = StreamsDB.getStreams();

    emit(state.copyWith(streams: streams));
  }

  Future<void> addStream(DateTime timeStartStream,
      List<HighlightModel> highlights, String title) async {
    final Duration durationStream = DateTime.now().difference(timeStartStream);
    final DateTime timeEndStream = timeStartStream.add(durationStream);

    final String startStream =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(timeStartStream);
    final String endStream =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(timeEndStream);

    StreamsDB.addStream(
      StreamModel(
        name: title,
        date: DateFormat('yyyy-MM-dd').format(timeStartStream),
        time: '$startStream - $endStream',
        highlights: highlights,
      ),
    );

    StreamsDB.deleteLiveStream();
  }

  Future<void> addLiveStream({
    required DateTime timeStartStream,
    required List<HighlightModel> highlights,
    required String title,
    required StreamModel? streamModel,
  }) async {
    if (streamModel != null) {
      StreamsDB.deleteLiveStream();
    }

    StreamsDB.addLiveStream(
      StreamModel(
        name: title,
        date: DateFormat('yyyy-MM-dd').format(timeStartStream),
        time: timeStartStream.toString(),
        highlights: highlights,
      ),
    );

    emit(state.copyWith(status: StreamStatus.ready));
  }

  Future<void> deleteStream(int index) async {
    StreamsDB.deleteStream(index);
    final streams = StreamsDB.getStreams();
    emit(state.copyWith(streams: streams));
  }

  Future<void> fetch() async {
    emit(state.copyWith(status: StreamStatus.loading));
    await Future.wait([
      loadingStreams(),
    ]);
    emit(state.copyWith(status: StreamStatus.ready));
  }
}
