// @link "deps/zlib/libz.a"

const std = @import("std");

test "Zlib Read" {
    const expected_text = @embedFile("./zlib.test.txt");
    const input = std.mem.span(@embedFile("./zlib.test.gz"));
    std.debug.print("zStream Size: {d}", .{@sizeOf(zStream_struct)});
    var output = std.ArrayList(u8).init(std.heap.c_allocator);
    var writer = output.writer();
    const ZlibReader = NewZlibReader(@TypeOf(&writer), 4096);

    var reader = try ZlibReader.init(&writer, input, std.heap.c_allocator);
    defer reader.deinit();
    try reader.readAll();

    try std.testing.expectEqualStrings(expected_text, output.items);
}

test "ZlibArrayList Read" {
    const expected_text = @embedFile("./zlib.test.txt");
    const input = std.mem.span(@embedFile("./zlib.test.gz"));
    std.debug.print("zStream Size: {d}", .{@sizeOf(zStream_struct)});
    var list = std.ArrayListUnmanaged(u8){};
    try list.ensureUnusedCapacity(std.heap.c_allocator, 4096);
    var reader = try ZlibReaderArrayList.init(input, &list, std.heap.c_allocator);
    defer reader.deinit();
    try reader.readAll();

    try std.testing.expectEqualStrings(expected_text, list.items);
}

pub extern fn zlibVersion() [*c]const u8;

pub extern fn compress(dest: [*c]Bytef, destLen: [*c]uLongf, source: [*c]const Bytef, sourceLen: uLong) c_int;
pub extern fn compress2(dest: [*c]Bytef, destLen: [*c]uLongf, source: [*c]const Bytef, sourceLen: uLong, level: c_int) c_int;
pub extern fn compressBound(sourceLen: uLong) uLong;
pub extern fn uncompress(dest: [*c]Bytef, destLen: [*c]uLongf, source: [*c]const Bytef, sourceLen: uLong) c_int;
pub const struct_gzFile_s = extern struct {
    have: c_uint,
    next: [*c]u8,
    pos: c_long,
};
pub const gzFile = [*c]struct_gzFile_s;

// https://zlib.net/manual.html#Stream
const Byte = u8;
const uInt = u32;
const uLong = u64;
const Bytef = Byte;
const charf = u8;
const intf = c_int;
const uIntf = uInt;
const uLongf = uLong;
const voidpc = ?*const c_void;
const voidpf = ?*c_void;
const voidp = ?*c_void;
const z_crc_t = c_uint;

// typedef voidpf (*alloc_func) OF((voidpf opaque, uInt items, uInt size));
// typedef void   (*free_func)  OF((voidpf opaque, voidpf address));

pub const z_alloc_fn = ?fn (*c_void, uInt, uInt) callconv(.C) voidpf;
pub const z_free_fn = ?fn (*c_void, *c_void) callconv(.C) void;

pub const struct_internal_state = extern struct {
    dummy: c_int,
};
// typedef struct z_stream_s {
//     z_const Bytef *next_in;  /* next input byte */
//     uInt     avail_in;  /* number of bytes available at next_in */
//     uLong    total_in;  /* total number of input bytes read so far */

//     Bytef    *next_out; /* next output byte will go here */
//     uInt     avail_out; /* remaining free space at next_out */
//     uLong    total_out; /* total number of bytes output so far */

//     z_const char *msg;  /* last error message, NULL if no error */
//     struct internal_state FAR *state; /* not visible by applications */

//     alloc_func zalloc;  /* used to allocate the internal state */
//     free_func  zfree;   /* used to free the internal state */
//     voidpf     opaque;  /* private data object passed to zalloc and zfree */

//     int     data_type;  /* best guess about the data type: binary or text
//                            for deflate, or the decoding state for inflate */
//     uLong   adler;      /* Adler-32 or CRC-32 value of the uncompressed data */
//     uLong   reserved;   /* reserved for future use */
// } z_stream;

pub const zStream_struct = extern struct {
    /// next input byte 
    next_in: [*c]const u8,
    /// number of bytes available at next_in 
    avail_in: uInt,
    /// total number of input bytes read so far 
    total_in: uLong,

    /// next output byte will go here 
    next_out: [*c]u8,
    /// remaining free space at next_out 
    avail_out: uInt,
    /// total number of bytes output so far 
    total_out: uLong,

    /// last error message, NULL if no error 
    err_msg: [*c]const u8,
    /// not visible by applications 
    internal_state: ?*struct_internal_state,

    /// used to allocate the internal state 
    alloc_func: z_alloc_fn,
    /// used to free the internal state 
    free_func: z_free_fn,
    /// private data object passed to zalloc and zfree 
    user_data: *c_void,

    /// best guess about the data type: binary or text for deflate, or the decoding state for inflate
    data_type: DataType,

    ///Adler-32 or CRC-32 value of the uncompressed data
    adler: uLong,
    /// reserved for future use
    reserved: uLong,
};

pub const z_stream = zStream_struct;
pub const z_streamp = [*c]z_stream;

// #define Z_BINARY   0
// #define Z_TEXT     1
// #define Z_ASCII    Z_TEXT   /* for compatibility with 1.2.2 and earlier */
// #define Z_UNKNOWN  2
pub const DataType = enum(c_int) {
    Binary = 0,
    Text = 1,
    Unknown = 2,
};

// #define Z_OK            0
// #define Z_STREAM_END    1
// #define Z_NEED_DICT     2
// #define Z_ERRNO        (-1)
// #define Z_STREAM_ERROR (-2)
// #define Z_DATA_ERROR   (-3)
// #define Z_MEM_ERROR    (-4)
// #define Z_BUF_ERROR    (-5)
// #define Z_VERSION_ERROR (-6)
pub const ReturnCode = enum(c_int) {
    Ok = 0,
    StreamEnd = 1,
    NeedDict = 2,
    ErrNo = -1,
    StreamError = -2,
    DataError = -3,
    MemError = -4,
    BufError = -5,
    VersionError = -6,
};

// #define Z_NO_FLUSH      0
// #define Z_PARTIAL_FLUSH 1
// #define Z_SYNC_FLUSH    2
// #define Z_FULL_FLUSH    3
// #define Z_FINISH        4
// #define Z_BLOCK         5
// #define Z_TREES         6
pub const FlushValue = enum(c_int) {
    NoFlush = 0,
    PartialFlush = 1,
    /// Z_SYNC_FLUSH requests that inflate() flush as much output as possible to the output buffer
    SyncFlush = 2,
    FullFlush = 3,
    Finish = 4,

    /// Z_BLOCK requests that inflate() stop if and when it gets to the next / deflate block boundary When decoding the zlib or gzip format, this will / cause inflate() to return immediately after the header and before the / first block. When doing a raw inflate, inflate() will go ahead and / process the first block, and will return when it gets to the end of that / block, or when it runs out of data. / The Z_BLOCK option assists in appending to or combining deflate streams. / To assist in this, on return inflate() always sets strm->data_type to the / number of unused bits in the last byte taken from strm->next_in, plus 64 / if inflate() is currently decoding the last block in the deflate stream, / plus 128 if inflate() returned immediately after decoding an end-of-block / code or decoding the complete header up to just before the first byte of / the deflate stream. The end-of-block will not be indicated until all of / the uncompressed data from that block has been written to strm->next_out. / The number of unused bits may in general be greater than seven, except / when bit 7 of data_type is set, in which case the number of unused bits / will be less than eight. data_type is set as noted here every time / inflate() returns for all flush options, and so can be used to determine / the amount of currently consumed input in bits.
    Block = 5,

    /// The Z_TREES option behaves as Z_BLOCK does, but it also returns when the end of each deflate block header is reached, before any actual data in that block is decoded. This allows the caller to determine the length of the deflate block header for later use in random access within a deflate block. 256 is added to the value of strm->data_type when inflate() returns immediately after reaching the end of the deflate block header.
    Trees = 6,
};

// ZEXTERN int ZEXPORT inflateInit OF((z_streamp strm));

/// Initializes the internal stream state for decompression. The fields next_in, avail_in, zalloc, zfree and opaque must be initialized before by the caller. In the current version of inflate, the provided input is not read or consumed. The allocation of a sliding window will be deferred to the first call of inflate (if the decompression does not complete on the first call). If zalloc and zfree are set to Z_NULL, inflateInit updates them to use default allocation functions.
///
/// inflateInit returns Z_OK if success, Z_MEM_ERROR if there was not enough memory, Z_VERSION_ERROR if the zlib library version is incompatible with the version assumed by the caller, or Z_STREAM_ERROR if the parameters are invalid, such as a null pointer to the structure. msg is set to null if there is no error message. inflateInit does not perform any decompression. Actual decompression will be done by inflate(). So next_in, and avail_in, next_out, and avail_out are unused and unchanged. The current implementation of inflateInit() does not process any header information—that is deferred until inflate() is called.
pub extern fn inflateInit_(strm: z_streamp, version: [*c]const u8, stream_size: c_int) ReturnCode;
pub extern fn inflateInit2_(strm: z_streamp, window_size: c_int, version: [*c]const u8, stream_size: c_int) ReturnCode;

/// inflate decompresses as much data as possible, and stops when the input buffer becomes empty or the output buffer becomes full. It may introduce some output latency (reading input without producing any output) except when forced to flush.
/// The detailed semantics are as follows. inflate performs one or both of the following actions:
///
/// - Decompress more input starting at next_in and update next_in and avail_in accordingly. If not all input can be processed (because there is not enough room in the output buffer), then next_in and avail_in are updated accordingly, and processing will resume at this point for the next call of inflate().
/// - Generate more output starting at next_out and update next_out and avail_out accordingly. inflate() provides as much output as possible, until there is no more input data or no more space in the output buffer (see below about the flush parameter).
///
/// Before the call of inflate(), the application should ensure that at least one of the actions is possible, by providing more input and/or consuming more output, and updating the next_* and avail_* values accordingly. If the caller of inflate() does not provide both available input and available output space, it is possible that there will be no progress made. The application can consume the uncompressed output when it wants, for example when the output buffer is full (avail_out == 0), or after each call of inflate(). If inflate returns Z_OK and with zero avail_out, it must be called again after making room in the output buffer because there might be more output pending.
///
/// The flush parameter of inflate() can be Z_NO_FLUSH, Z_SYNC_FLUSH, Z_FINISH, Z_BLOCK, or Z_TREES. Z_SYNC_FLUSH requests that inflate() flush as much output as possible to the output buffer. Z_BLOCK requests that inflate() stop if and when it gets to the next deflate block boundary. When decoding the zlib or gzip format, this will cause inflate() to return immediately after the header and before the first block. When doing a raw inflate, inflate() will go ahead and process the first block, and will return when it gets to the end of that block, or when it runs out of data.
///
/// The Z_BLOCK option assists in appending to or combining deflate streams. To assist in this, on return inflate() always sets strm->data_type to the number of unused bits in the last byte taken from strm->next_in, plus 64 if inflate() is currently decoding the last block in the deflate stream, plus 128 if inflate() returned immediately after decoding an end-of-block code or decoding the complete header up to just before the first byte of the deflate stream. The end-of-block will not be indicated until all of the uncompressed data from that block has been written to strm->next_out. The number of unused bits may in general be greater than seven, except when bit 7 of data_type is set, in which case the number of unused bits will be less than eight. data_type is set as noted here every time inflate() returns for all flush options, and so can be used to determine the amount of currently consumed input in bits.
///
/// The Z_TREES option behaves as Z_BLOCK does, but it also returns when the end of each deflate block header is reached, before any actual data in that block is decoded. This allows the caller to determine the length of the deflate block header for later use in random access within a deflate block. 256 is added to the value of strm->data_type when inflate() returns immediately after reaching the end of the deflate block header.
///
/// inflate() should normally be called until it returns Z_STREAM_END or an error. However if all decompression is to be performed in a single step (a single call of inflate), the parameter flush should be set to Z_FINISH. In this case all pending input is processed and all pending output is flushed; avail_out must be large enough to hold all of the uncompressed data for the operation to complete. (The size of the uncompressed data may have been saved by the compressor for this purpose.) The use of Z_FINISH is not required to perform an inflation in one step. However it may be used to inform inflate that a faster approach can be used for the single inflate() call. Z_FINISH also informs inflate to not maintain a sliding window if the stream completes, which reduces inflate's memory footprint. If the stream does not complete, either because not all of the stream is provided or not enough output space is provided, then a sliding window will be allocated and inflate() can be called again to continue the operation as if Z_NO_FLUSH had been used.
///
/// In this implementation, inflate() always flushes as much output as possible to the output buffer, and always uses the faster approach on the first call. So the effects of the flush parameter in this implementation are on the return value of inflate() as noted below, when inflate() returns early when Z_BLOCK or Z_TREES is used, and when inflate() avoids the allocation of memory for a sliding window when Z_FINISH is used.
///
/// If a preset dictionary is needed after this call (see inflateSetDictionary below), inflate sets strm->adler to the Adler-32 checksum of the dictionary chosen by the compressor and returns Z_NEED_DICT; otherwise it sets strm->adler to the Adler-32 checksum of all output produced so far (that is, total_out bytes) and returns Z_OK, Z_STREAM_END or an error code as described below. At the end of the stream, inflate() checks that its computed Adler-32 checksum is equal to that saved by the compressor and returns Z_STREAM_END only if the checksum is correct.
///
/// inflate() will decompress and check either zlib-wrapped or gzip-wrapped deflate data. The header type is detected automatically, if requested when initializing with inflateInit2(). Any information contained in the gzip header is not retained unless inflateGetHeader() is used. When processing gzip-wrapped deflate data, strm->adler32 is set to the CRC-32 of the output produced so far. The CRC-32 is checked against the gzip trailer, as is the uncompressed length, modulo 2^32.
///
/// inflate() returns Z_OK if some progress has been made (more input processed or more output produced), Z_STREAM_END if the end of the compressed data has been reached and all uncompressed output has been produced, Z_NEED_DICT if a preset dictionary is needed at this point, Z_DATA_ERROR if the input data was corrupted (input stream not conforming to the zlib format or incorrect check value, in which case strm->msg points to a string with a more specific error), Z_STREAM_ERROR if the stream structure was inconsistent (for example next_in or next_out was Z_NULL, or the state was inadvertently written over by the application), Z_MEM_ERROR if there was not enough memory, Z_BUF_ERROR if no progress was possible or if there was not enough room in the output buffer when Z_FINISH is used. Note that Z_BUF_ERROR is not fatal, and inflate() can be called again with more input and more output space to continue decompressing. If Z_DATA_ERROR is returned, the application may then call inflateSync() to look for a good compression block if a partial recovery of the data is to be attempted.
extern fn inflate(stream: [*c]zStream_struct, flush: FlushValue) ReturnCode;

/// inflateEnd returns Z_OK if success, or Z_STREAM_ERROR if the stream state was inconsistent.
const InflateEndResult = enum(c_int) {
    Ok = 0,
    StreamEnd = 1,
};

/// All dynamically allocated data structures for this stream are freed. This function discards any unprocessed input and does not flush any pending output.
extern fn inflateEnd(stream: [*c]zStream_struct) InflateEndResult;

pub fn NewZlibReader(comptime Writer: type, comptime buffer_size: usize) type {
    return struct {
        const ZlibReader = @This();
        pub const State = enum {
            Uninitialized,
            Inflating,
            End,
            Error,
        };

        context: Writer,
        input: []const u8,
        buf: [buffer_size]u8,
        zlib: zStream_struct,
        allocator: *std.mem.Allocator,
        arena: std.heap.ArenaAllocator,
        state: State = State.Uninitialized,

        pub fn alloc(ctx: *c_void, items: uInt, len: uInt) callconv(.C) *c_void {
            var this = @ptrCast(*ZlibReader, @alignCast(@alignOf(*ZlibReader), ctx));
            const buf = this.arena.allocator.alloc(u8, items * len) catch unreachable;
            return buf.ptr;
        }

        // we free manually all at once
        pub fn free(ctx: *c_void, ptr: *c_void) callconv(.C) void {}

        pub fn deinit(this: *ZlibReader) void {
            var allocator = this.allocator;
            this.end();
            this.arena.deinit();
            allocator.destroy(this);
        }

        pub fn end(this: *ZlibReader) void {
            if (this.state == State.Inflating) {
                _ = inflateEnd(&this.zlib);
                this.state = State.End;
            }
        }

        pub fn init(writer: Writer, input: []const u8, allocator: *std.mem.Allocator) !*ZlibReader {
            var zlib_reader = try allocator.create(ZlibReader);
            zlib_reader.* = ZlibReader{
                .context = writer,
                .input = input,
                .buf = std.mem.zeroes([buffer_size]u8),
                .allocator = allocator,
                .zlib = undefined,
                .arena = std.heap.ArenaAllocator.init(allocator),
            };

            zlib_reader.zlib = zStream_struct{
                .next_in = input.ptr,
                .avail_in = @intCast(uInt, input.len),
                .total_in = @intCast(uInt, input.len),

                .next_out = &zlib_reader.buf,
                .avail_out = buffer_size,
                .total_out = buffer_size,

                .err_msg = null,
                .alloc_func = ZlibReader.alloc,
                .free_func = ZlibReader.free,

                .internal_state = null,
                .user_data = zlib_reader,

                .data_type = DataType.Unknown,
                .adler = 0,
                .reserved = 0,
            };

            switch (inflateInit2_(&zlib_reader.zlib, 15 + 32, zlibVersion(), @sizeOf(zStream_struct))) {
                ReturnCode.Ok => return zlib_reader,
                ReturnCode.MemError => {
                    zlib_reader.deinit();
                    return error.OutOfMemory;
                },
                ReturnCode.StreamError => {
                    zlib_reader.deinit();
                    return error.InvalidArgument;
                },
                ReturnCode.VersionError => {
                    zlib_reader.deinit();
                    return error.InvalidArgument;
                },
                else => unreachable,
            }
        }

        pub fn errorMessage(this: *ZlibReader) ?[]const u8 {
            if (this.zlib.err_msg) |msg_ptr| {
                return std.mem.sliceTo(msg_ptr, 0);
            }

            return null;
        }

        pub fn readAll(this: *ZlibReader) !void {
            while (this.state == State.Uninitialized or this.state == State.Inflating) {

                // Before the call of inflate(), the application should ensure
                // that at least one of the actions is possible, by providing
                // more input and/or consuming more output, and updating the
                // next_* and avail_* values accordingly. If the caller of
                // inflate() does not provide both available input and available
                // output space, it is possible that there will be no progress
                // made. The application can consume the uncompressed output
                // when it wants, for example when the output buffer is full
                // (avail_out == 0), or after each call of inflate(). If inflate
                // returns Z_OK and with zero avail_out, it must be called again
                // after making room in the output buffer because there might be
                // more output pending.

                // - Decompress more input starting at next_in and update
                //   next_in and avail_in accordingly. If not all input can be
                //   processed (because there is not enough room in the output
                //   buffer), then next_in and avail_in are updated accordingly,
                //   and processing will resume at this point for the next call
                //   of inflate().

                // - Generate more output starting at next_out and update
                //   next_out and avail_out accordingly. inflate() provides as
                //   much output as possible, until there is no more input data
                //   or no more space in the output buffer (see below about the
                //   flush parameter).

                if (this.zlib.avail_out == 0) {
                    var written = try this.context.write(&this.buf);
                    while (written < this.zlib.avail_out) {
                        written += try this.context.write(this.buf[written..]);
                    }
                    this.zlib.avail_out = buffer_size;
                    this.zlib.next_out = &this.buf;
                }

                if (this.zlib.avail_in == 0) {
                    return error.ShortRead;
                }

                const rc = inflate(&this.zlib, FlushValue.PartialFlush);
                this.state = State.Inflating;

                switch (rc) {
                    ReturnCode.StreamEnd => {
                        this.state = State.End;
                        var remainder = this.buf[0 .. buffer_size - this.zlib.avail_out];
                        remainder = remainder[try this.context.write(remainder)..];
                        while (remainder.len > 0) {
                            remainder = remainder[try this.context.write(remainder)..];
                        }
                        this.end();
                        return;
                    },
                    ReturnCode.MemError => {
                        this.state = State.Error;
                        return error.OutOfMemory;
                    },
                    ReturnCode.StreamError,
                    ReturnCode.DataError,
                    ReturnCode.BufError,
                    ReturnCode.NeedDict,
                    ReturnCode.VersionError,
                    ReturnCode.ErrNo,
                    => {
                        this.state = State.Error;
                        return error.ZlibError;
                    },
                    ReturnCode.Ok => {},
                }
            }
        }
    };
}

pub const ZlibReaderArrayList = struct {
    const ZlibReader = ZlibReaderArrayList;
    pub const State = enum {
        Uninitialized,
        Inflating,
        End,
        Error,
    };

    input: []const u8,
    list: std.ArrayListUnmanaged(u8),
    list_ptr: *std.ArrayListUnmanaged(u8),
    zlib: zStream_struct,
    allocator: *std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    state: State = State.Uninitialized,

    pub fn alloc(ctx: *c_void, items: uInt, len: uInt) callconv(.C) *c_void {
        var this = @ptrCast(*ZlibReader, @alignCast(@alignOf(*ZlibReader), ctx));
        const buf = this.arena.allocator.alloc(u8, items * len) catch unreachable;
        return buf.ptr;
    }

    // we free manually all at once
    pub fn free(ctx: *c_void, ptr: *c_void) callconv(.C) void {}

    pub fn deinit(this: *ZlibReader) void {
        var allocator = this.allocator;
        this.end();
        this.arena.deinit();
        allocator.destroy(this);
    }

    pub fn end(this: *ZlibReader) void {
        if (this.state == State.Inflating) {
            _ = inflateEnd(&this.zlib);
            this.state = State.End;
        }
    }

    pub fn init(input: []const u8, list: *std.ArrayListUnmanaged(u8), allocator: *std.mem.Allocator) !*ZlibReader {
        var zlib_reader = try allocator.create(ZlibReader);
        zlib_reader.* = ZlibReader{
            .input = input,
            .list = list.*,
            .list_ptr = list,
            .allocator = allocator,
            .zlib = undefined,
            .arena = std.heap.ArenaAllocator.init(allocator),
        };

        zlib_reader.zlib = zStream_struct{
            .next_in = input.ptr,
            .avail_in = @intCast(uInt, input.len),
            .total_in = @intCast(uInt, input.len),

            .next_out = zlib_reader.list.items.ptr,
            .avail_out = @intCast(u32, zlib_reader.list.items.len),
            .total_out = zlib_reader.list.items.len,

            .err_msg = null,
            .alloc_func = ZlibReader.alloc,
            .free_func = ZlibReader.free,

            .internal_state = null,
            .user_data = zlib_reader,

            .data_type = DataType.Unknown,
            .adler = 0,
            .reserved = 0,
        };

        switch (inflateInit2_(&zlib_reader.zlib, 15 + 32, zlibVersion(), @sizeOf(zStream_struct))) {
            ReturnCode.Ok => return zlib_reader,
            ReturnCode.MemError => {
                zlib_reader.deinit();
                return error.OutOfMemory;
            },
            ReturnCode.StreamError => {
                zlib_reader.deinit();
                return error.InvalidArgument;
            },
            ReturnCode.VersionError => {
                zlib_reader.deinit();
                return error.InvalidArgument;
            },
            else => unreachable,
        }
    }

    pub fn errorMessage(this: *ZlibReader) ?[]const u8 {
        if (this.zlib.err_msg) |msg_ptr| {
            return std.mem.sliceTo(msg_ptr, 0);
        }

        return null;
    }

    pub fn readAll(this: *ZlibReader) !void {
        defer {
            this.list.shrinkRetainingCapacity(this.zlib.total_out);
            this.list_ptr.* = this.list;
        }

        while (this.state == State.Uninitialized or this.state == State.Inflating) {

            // Before the call of inflate(), the application should ensure
            // that at least one of the actions is possible, by providing
            // more input and/or consuming more output, and updating the
            // next_* and avail_* values accordingly. If the caller of
            // inflate() does not provide both available input and available
            // output space, it is possible that there will be no progress
            // made. The application can consume the uncompressed output
            // when it wants, for example when the output buffer is full
            // (avail_out == 0), or after each call of inflate(). If inflate
            // returns Z_OK and with zero avail_out, it must be called again
            // after making room in the output buffer because there might be
            // more output pending.

            // - Decompress more input starting at next_in and update
            //   next_in and avail_in accordingly. If not all input can be
            //   processed (because there is not enough room in the output
            //   buffer), then next_in and avail_in are updated accordingly,
            //   and processing will resume at this point for the next call
            //   of inflate().

            // - Generate more output starting at next_out and update
            //   next_out and avail_out accordingly. inflate() provides as
            //   much output as possible, until there is no more input data
            //   or no more space in the output buffer (see below about the
            //   flush parameter).

            if (this.zlib.avail_out == 0) {
                const initial = this.list.items.len;
                try this.list.ensureUnusedCapacity(this.allocator, 4096);
                this.list.expandToCapacity();
                this.zlib.next_out = &this.list.items[initial];
                this.zlib.avail_out = @intCast(u32, this.list.items.len - initial);
            }

            if (this.zlib.avail_in == 0) {
                return error.ShortRead;
            }

            const rc = inflate(&this.zlib, FlushValue.PartialFlush);
            this.state = State.Inflating;

            switch (rc) {
                ReturnCode.StreamEnd => {
                    this.state = State.End;

                    this.end();
                    return;
                },
                ReturnCode.MemError => {
                    this.state = State.Error;
                    return error.OutOfMemory;
                },
                ReturnCode.StreamError,
                ReturnCode.DataError,
                ReturnCode.BufError,
                ReturnCode.NeedDict,
                ReturnCode.VersionError,
                ReturnCode.ErrNo,
                => {
                    this.state = State.Error;
                    return error.ZlibError;
                },
                ReturnCode.Ok => {},
            }
        }
    }
};