//
//  ZipStr.m
//  adi
//
//  Created by LIU Zhongjie on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <zlib.h>
#import "ZipStr.h"

@implementation ZipStr

#define Z_BUFSIZE 4096
#define ASCII_FLAG   0x01 /* bit 0 set: file probably ascii text */
#define HEAD_CRC     0x02 /* bit 1 set: header CRC present */
#define EXTRA_FIELD  0x04 /* bit 2 set: extra field present */
#define ORIG_NAME    0x08 /* bit 3 set: original file name present */
#define COMMENT      0x10 /* bit 4 set: file comment present */
#define RESERVED     0xE0 /* bits 5..7: reserved */

static const int gz_magic[2] = {0x1f, 0x8b}; /* gzip magic header */

typedef  unsigned char GZIP;
typedef  GZIP* LPGZIP;

const int t_nBufferLength = 1024;
char m_buffer[t_nBufferLength + 1];
int m_CurrentBufferSize;
z_stream m_zstream;
int      m_z_err;   /* error code for last stream operation */
Byte     *m_inbuf; /* output buffer */
uLong    m_crc;     /* crc32 of uncompressed data */
int      m_z_eof;
int      m_transparent;

int      m_pos;
LPGZIP   m_gzip;
int      m_gziplen;

char* psz;
int Length;

int destroy()
{
    int err = Z_OK;
    if (m_zstream.state != NULL)
    {
        err = inflateEnd(&m_zstream);
    }
    if (m_z_err < 0) err = m_z_err;
    if (m_inbuf)
        free(m_inbuf);
    return err;
}

int rread(LPGZIP buf, int size)
{
    int nRead = size;
    if (m_pos + size >= m_gziplen)
    {
        nRead = m_gziplen - m_pos;
    }
    if (nRead <= 0) return 0;
    memcpy(buf, m_gzip + m_pos, nRead);
    m_pos += nRead;
    return nRead;
}

int get_byte()
{
    if (m_z_eof) return EOF;
    if (m_zstream.avail_in == 0) 
    {
        errno = 0;
        m_zstream.avail_in = rread(m_inbuf, Z_BUFSIZE);
        if(m_zstream.avail_in == 0)
        {
            m_z_eof = 1;
            return EOF;
        }
        m_zstream.next_in = m_inbuf;
    }
    m_zstream.avail_in--;
    return *(m_zstream.next_in)++;
}

void check_header()
{
    int method; /* method byte */
    int flags;  /* flags byte */
    uInt len;
    int c;
    
    /* Check the gzip magic header */
    for (len = 0; len < 2; len++) {
        c = get_byte();
        if (c != gz_magic[len]) {
            if (len != 0) m_zstream.avail_in++, m_zstream.next_in--;
            if (c != EOF) {
                m_zstream.avail_in++, m_zstream.next_in--;
                m_transparent = 1;
            }
            m_z_err = m_zstream.avail_in != 0 ? Z_OK : Z_STREAM_END;
            return;
        }
    }
    method = get_byte();
    flags = get_byte();
    if (method != Z_DEFLATED || (flags & RESERVED) != 0) {
        m_z_err = Z_DATA_ERROR;
        return;
    }
    /* Discard time, xflags and OS code: */
    for (len = 0; len < 6; len++) (void)get_byte();
    
    if ((flags & EXTRA_FIELD) != 0) { /* skip the extra field */
        len  =  (uInt) get_byte();
        len += ((uInt) get_byte()) << 8;
        /* len is garbage if EOF but the loop below will quit anyway */
        while (len-- != 0 && get_byte() != EOF) ;
    }
    if ((flags & ORIG_NAME) != 0) { /* skip the original file name */
        while ((c = get_byte()) != 0 && c != EOF) ;
    }
    if ((flags & COMMENT) != 0) {   /* skip the .gz file comment */
        while ((c = get_byte()) != 0 && c != EOF) ;
    }
    if ((flags & HEAD_CRC) != 0) {  /* skip the header crc */
        for (len = 0; len < 2; len++) (void)get_byte();
    }
    m_z_err = m_z_eof ? Z_DATA_ERROR : Z_OK;
}

uLong getLong()
{
    uLong x = (uLong)get_byte();
    int c;
    x += ((uLong)get_byte())<<8;
    x += ((uLong)get_byte())<<16;
    c = get_byte();
    if (c == EOF) m_z_err = Z_DATA_ERROR;
    x += ((uLong)c)<<24;
    return x;
}

int ggzread(char* buf,int len)
{
    Bytef *start = (Bytef*)buf; /* starting point for crc computation */
    Byte  *next_out; /* == stream.next_out but not forced far (for MSDOS) */
    
    
    if (m_z_err == Z_DATA_ERROR || m_z_err == Z_ERRNO) return -1;
    if (m_z_err == Z_STREAM_END) return 0;  /* EOF */
    
    next_out = (Byte*)buf;
    m_zstream.next_out = (Bytef*)buf;
    m_zstream.avail_out = len;
    while (m_zstream.avail_out != 0) {
        if (m_transparent)
        {
            /* Copy first the lookahead bytes: */
            uInt n = m_zstream.avail_in;
            if (n > m_zstream.avail_out) n = m_zstream.avail_out;
            if (n > 0) 
            {
                memcpy(m_zstream.next_out,m_zstream.next_in, n);
                next_out += n;
                m_zstream.next_out = next_out;
                m_zstream.next_in   += n;
                m_zstream.avail_out -= n;
                m_zstream.avail_in  -= n;
            }
            if (m_zstream.avail_out > 0) {
                m_zstream.avail_out -=rread(next_out,m_zstream.avail_out);
            }
            len -= m_zstream.avail_out;
            m_zstream.total_in  += (uLong)len;
            m_zstream.total_out += (uLong)len;
            if (len == 0) m_z_eof = 1;
            return (int)len;
        }
        if (m_zstream.avail_in == 0 && !m_z_eof)
        {
            errno = 0;
            m_zstream.avail_in = rread(m_inbuf,Z_BUFSIZE);
            if (m_zstream.avail_in == 0)
            {
                m_z_eof = 1;
            }
            m_zstream.next_in = m_inbuf;
        }
        m_z_err = inflate(&(m_zstream), Z_NO_FLUSH);
        if (m_z_err == Z_STREAM_END)
        {
            /* Check CRC and original size */
            m_crc = crc32(m_crc, start, (uInt)(m_zstream.next_out - start));
            start = m_zstream.next_out;
            if (getLong() != m_crc) {
                m_z_err = Z_DATA_ERROR;
            }else
            {
                (void)getLong();
                check_header();
                if (m_z_err == Z_OK)
                {
                    uLong total_in = m_zstream.total_in;
                    uLong total_out = m_zstream.total_out;
                    inflateReset(&(m_zstream));
                    m_zstream.total_in = total_in;
                    m_zstream.total_out = total_out;
                    m_crc = crc32(0L, Z_NULL, 0);
                }
            }
        }
        if (m_z_err != Z_OK || m_z_eof) break;
    }
    m_crc = crc32(m_crc, start, (uInt)(m_zstream.next_out - start));
    return (int)(len - m_zstream.avail_out);
}

int wwrite(char* buf,int count)
{
    if (buf == 0) return 0;
    if (Length + count > m_CurrentBufferSize)
    {
        int nTimes = (Length + count) / t_nBufferLength + 1;
        char* pTemp = psz;
        psz = (char*) malloc(nTimes * t_nBufferLength + 1);
        m_CurrentBufferSize = nTimes * t_nBufferLength;
        memset(psz, 0, m_CurrentBufferSize + 1);
        memcpy(psz, pTemp, Length);
        if (pTemp != m_buffer) free(pTemp);
    }
    memcpy(psz + Length, buf, count);
    Length += count;
    return count;
}

void Init()
{
    if(m_gzip==0)
    {
        psz=0; 
        Length=0;
        return ;
    }
    m_CurrentBufferSize=t_nBufferLength;
    psz=m_buffer;
    memset(psz,0,m_CurrentBufferSize+1);
    
    m_zstream.zalloc = (alloc_func)0;
    m_zstream.zfree = (free_func)0;
    m_zstream.opaque = (voidpf)0;
    m_zstream.next_in = m_inbuf = Z_NULL;
    m_zstream.next_out = Z_NULL;
    m_zstream.avail_in = m_zstream.avail_out = 0;
    m_z_err = Z_OK;
    m_z_eof = 0;
    m_transparent = 0;
    m_crc = crc32(0L, Z_NULL, 0);
    
    m_zstream.next_in = m_inbuf = (Byte*) malloc(Z_BUFSIZE);
    int err = inflateInit2(&m_zstream, -MAX_WBITS);
    if (err != Z_OK || m_inbuf == Z_NULL)
    {
        destroy();
        return;
    }
    m_zstream.avail_out = Z_BUFSIZE;
    check_header();
    char outbuf[Z_BUFSIZE];
    int nRead;
    while(true)
    {
        nRead = ggzread(outbuf, Z_BUFSIZE);
        if (nRead <= 0) break;
        wwrite(outbuf, nRead);
    }
    destroy();
}

void CGZIP2AT(LPGZIP pgzip, int len)
{
    m_gzip = pgzip;
    m_gziplen = len;
    psz = 0;
    Length = 0;
    m_pos = 0;
    Init(); 
}

//int gzip_uncompress(const Bytef *source, uLong sourceLen, NSMutableString* dst)
//{
//    z_stream stream;
//    
//    stream.next_in = (Bytef*)source;
//    stream.avail_in = (uInt)sourceLen;
//    
//    stream.next_out = NULL;
//    stream.avail_out = 0;
//    
//    stream.zalloc = (alloc_func)0;
//    stream.zfree = (free_func)0;
//    
//    
//    int err = inflateInit2(&stream, MAX_WBITS + 32);
//    if (err != Z_OK) 
//        return err;
//    
//    size_t nBufferSize = 4*1024;//! 16KB
//    Bytef *pBuffer = (Bytef*) malloc(nBufferSize);
//    memset(pBuffer, 0, nBufferSize);
//    
//    while(true)
//    {
//        stream.next_out = pBuffer;
//        stream.avail_out = nBufferSize;
//        
//        err = inflate(&stream, Z_SYNC_FLUSH);
//        if (err == Z_OK && stream.avail_out == 0)
//        {
//            NSString* str = [[NSString alloc] initWithBytes: pBuffer length: nBufferSize encoding: NSASCIIStringEncoding];
//            [dst appendString: [NSString stringWithString: str]];
//            [str release];
//        }
//        else if (err == Z_OK)
//        {
//            NSString* str = [[NSString alloc] initWithBytes: pBuffer length: nBufferSize - stream.avail_out encoding: NSASCIIStringEncoding];
//            [dst appendString: [NSString stringWithString: str]];
//            [str release];
//            break;
//        }
//        else
//        {
//            free(pBuffer);
//            inflateEnd(&stream);
//            if (err == Z_NEED_DICT || (err == Z_BUF_ERROR && stream.avail_in == 0))
//                return Z_DATA_ERROR;
//            return err;
//        }
//    }
//    
//    free(pBuffer);
//    
//    err = inflateEnd(&stream);
//    return err;
//}

+ (char*) Compress: (char*) str length: (int) sourceLen
{
    @try
    {
        if (str == NULL)
            return NULL;

        uLongf destLen;
        Bytef* dest = (Bytef*) malloc(sourceLen);
        compress(dest, &destLen, (const Bytef*) str, sourceLen);

        char* ret = (char*) malloc(destLen + 1);
        memcpy(ret, dest, destLen);
        ret[destLen] = '\0';
        free(dest);
        
        return ret;
    }
    @catch (NSException* e)
    {
        return NULL;
    }
}

+ (char*) Uncompress: (char*) str length: (int) sourceLen
{
    @try
    {
        if (str == NULL)
            return NULL;

//    NSMutableString* dst = [[NSMutableString alloc] init];
//    gzip_uncompress((const Bytef*) str, sourceLen, dst);
//    char* ret = (char*) malloc([dst length] + 1);
//    strcpy(ret, [dst UTF8String]);
//    ret[[dst length]] = '\0';
//    [dst release];
//    return ret;
        CGZIP2AT((LPGZIP) str, sourceLen);
        if (psz == NULL || sourceLen == Length || strcmp(str, psz) == 0)
        {
            if (psz != m_buffer && psz)
                free(psz);
            return NULL;
        }
        char* ret = (char*) malloc(Length + 1);
        memcpy(ret, psz, Length);
        ret[Length] = '\0';
        if (psz != m_buffer && psz)
            free(psz);
        return ret;
    }
    @catch (NSException* e)
    {
        return NULL;
    }
}

@end