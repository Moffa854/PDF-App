// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfCacheModelAdapter extends TypeAdapter<PdfCacheModel> {
  @override
  final int typeId = 1;

  @override
  PdfCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfCacheModel(
      originalPath: fields[0] as String,
      cachePath: fields[1] as String,
      lastAccessed: fields[2] as DateTime,
      lastModified: fields[3] as DateTime,
      fileSize: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PdfCacheModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.originalPath)
      ..writeByte(1)
      ..write(obj.cachePath)
      ..writeByte(2)
      ..write(obj.lastAccessed)
      ..writeByte(3)
      ..write(obj.lastModified)
      ..writeByte(4)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
