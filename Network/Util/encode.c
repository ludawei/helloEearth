//
//  encode.c
//  ChinaWeather
//
//  Created by 卢大维 on 14-7-22.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#include <stdio.h>
//gcc -lssl test.c -o test
#include <openssl/hmac.h>
#include <ctype.h>
#include <math.h>
#include <iconv.h>
#include <string.h>
#include <stdint.h>
typedef uintptr_t       ngx_uint_t;
#define NGX_UNESCAPE_URI       1
#define NGX_UNESCAPE_REDIRECT  2

#define NGX_ESCAPE_URI            0
#define NGX_ESCAPE_ARGS           1
#define NGX_ESCAPE_URI_COMPONENT  2
#define NGX_ESCAPE_HTML           3
#define NGX_ESCAPE_REFRESH        4
#define NGX_ESCAPE_MEMCACHED      5
#define NGX_ESCAPE_MAIL_AUTH      6
typedef struct {
	size_t      len;
	char     *data;
} ngx_str_t;

unsigned char *php_base64_encode( ngx_str_t src)   //php_base64_encode_ex
{//attention please,this function wounld return a string which ends with '\0'
	static const char base64_table[] =
	{ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', '\0'
	};
	static const char base64_pad = '=';
	const unsigned char *current = (const unsigned char *)src.data;
	int length = (int)src.len;
	unsigned char *p;
	unsigned char *result;
	//printf("in: php_base64_encode\n");
	if ((length + 2) < 0 || ((length + 2) / 3) >= (1 << (sizeof(int) * 8 - 2))) {
		return NULL;
	}
    
	result = (unsigned char *)malloc(((length + 2) / 3) * 4 * sizeof(char) + 1);//attention!!!!!free the memory after use!!!!//ÒÑŒì²é£ºÄÚŽæÊÍ·Å
	p = result;
    
	while (length > 2) {
		*p++ = base64_table[current[0] >> 2];
		*p++ = base64_table[((current[0] & 0x03) << 4) + (current[1] >> 4)];
		*p++ = base64_table[((current[1] & 0x0f) << 2) + (current[2] >> 6)];
		*p++ = base64_table[current[2] & 0x3f];
		current += 3;
		length -= 3;
	}
	if (length != 0) {
		*p++ = base64_table[current[0] >> 2];
		if (length > 1) {
			*p++ = base64_table[((current[0] & 0x03) << 4) + (current[1] >> 4)];
			*p++ = base64_table[(current[1] & 0x0f) << 2];
			*p++ = base64_pad;
		} else {
			*p++ = base64_table[(current[0] & 0x03) << 4];
			*p++ = base64_pad;
			*p++ = base64_pad;
		}
	}
	*p = '\0';
	return result;
}
uintptr_t
ngx_escape_uri(char *dst, char *src, size_t size, ngx_uint_t type)
{
    ngx_uint_t      n;
    uint32_t       *escape;
    static char   hex[] = "0123456789abcdef";
    
    /* " ", "#", "%", "?", %00-%1F, %7F-%FF */
    
    static uint32_t   uri[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0x80000029, /* 1000 0000 0000 0000  0000 0000 0010 1001 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0x80000000, /* 1000 0000 0000 0000  0000 0000 0000 0000 */
        
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff  /* 1111 1111 1111 1111  1111 1111 1111 1111 */
    };
    
    /* " ", "#", "%", "&", "+", "?", %00-%1F, %7F-%FF */
    
    static uint32_t   args[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0x88000869, /* 1000 1000 0000 0000  0000 1000 0110 1001 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0x80000000, /* 1000 0000 0000 0000  0000 0000 0000 0000 */
        
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff  /* 1111 1111 1111 1111  1111 1111 1111 1111 */
    };
    
    /* not ALPHA, DIGIT, "-", ".", "_", "~" */
    
    static uint32_t   uri_component[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0xfc009fff, /* 1111 1100 0000 0000  1001 1111 1111 1111 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x78000001, /* 0111 1000 0000 0000  0000 0000 0000 0001 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0xb8000001, /* 1011 1000 0000 0000  0000 0000 0000 0001 */
        
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff  /* 1111 1111 1111 1111  1111 1111 1111 1111 */
    };
    
    /* " ", "#", """, "%", "'", %00-%1F, %7F-%FF */
    
    static uint32_t   html[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0x000000ad, /* 0000 0000 0000 0000  0000 0000 1010 1101 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0x80000000, /* 1000 0000 0000 0000  0000 0000 0000 0000 */
        
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff  /* 1111 1111 1111 1111  1111 1111 1111 1111 */
    };
    
    /* " ", """, "%", "'", %00-%1F, %7F-%FF */
    
    static uint32_t   refresh[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0x00000085, /* 0000 0000 0000 0000  0000 0000 1000 0101 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0x80000000, /* 1000 0000 0000 0000  0000 0000 0000 0000 */
        
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        0xffffffff  /* 1111 1111 1111 1111  1111 1111 1111 1111 */
    };
    
    /* " ", "%", %00-%1F */
    
    static uint32_t   memcached[] = {
        0xffffffff, /* 1111 1111 1111 1111  1111 1111 1111 1111 */
        
        /* ?>=< ;:98 7654 3210  /.-, +*)( '&%$ #"!  */
        0x00000021, /* 0000 0000 0000 0000  0000 0000 0010 0001 */
        
        /* _^]\ [ZYX WVUT SRQP  ONML KJIH GFED CBA@ */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        /*  ~}| {zyx wvut srqp  onml kjih gfed cba` */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
        0x00000000, /* 0000 0000 0000 0000  0000 0000 0000 0000 */
    };
    
    /* mail_auth is the same as memcached */
    
    static uint32_t  *map[] =
    { uri, args, uri_component, html, refresh, memcached, memcached };
    
    
    escape = map[type];
    
    if (dst == NULL) {
        
        /* find the number of the characters to be escaped */
        
        n = 0;
        
        while (size) {
            if (escape[*src >> 5] & (1 << (*src & 0x1f))) {
                n++;
            }
            src++;
            size--;
        }
        
        return (uintptr_t) n;
    }
    
    while (size) {
        if (escape[*src >> 5] & (1 << (*src & 0x1f))) {
            *dst++ = '%';
            *dst++ = hex[*src >> 4];
            *dst++ = hex[*src & 0xf];
            src++;
            
        } else {
            *dst++ = *src++;
        }
        size--;
    }
    
    return (uintptr_t) dst;
}
void ngx_unescape_uri(char **dst, char **src, size_t size, ngx_uint_t type)
{
	
	char  *d, *s, ch, c, decoded;
	enum {
		sw_usual = 0,
		sw_quoted,
		sw_quoted_second
	} state;
	//printf("in: ngx_unescape_uri\n");
	d = *dst;
	s = *src;
    
	state = 0;
	decoded = 0;
    
	while (size--) {
        
		ch = *s++;
        
		switch (state) {
            case sw_usual:
                if (ch == '?'
                    && (type & (NGX_UNESCAPE_URI|NGX_UNESCAPE_REDIRECT)))
                {
                    *d++ = ch;
                    goto done;
                }
                
                if (ch == '%') {
                    state = sw_quoted;
                    break;
                }
                
                *d++ = ch;
                break;
                
            case sw_quoted:
                
                if (ch >= '0' && ch <= '9') {
                    decoded = (char) (ch - '0');
                    state = sw_quoted_second;
                    break;
                }
                
                c = (char) (ch | 0x20);
                if (c >= 'a' && c <= 'f') {
                    decoded = (char) (c - 'a' + 10);
                    state = sw_quoted_second;
                    break;
                }
                
                /* the invalid quoted character */
                
                state = sw_usual;
                
                *d++ = ch;
                
                break;
                
            case sw_quoted_second:
                
                state = sw_usual;
                
                if (ch >= '0' && ch <= '9') {
                    ch = (char) ((decoded << 4) + ch - '0');
                    
                    if (type & NGX_UNESCAPE_REDIRECT) {
                        if (ch > '%' && ch < 0x7f) {
                            *d++ = ch;
                            break;
                        }
                        
                        *d++ = '%'; *d++ = *(s - 2); *d++ = *(s - 1);
                        
                        break;
                    }
                    
                    *d++ = ch;
                    
                    break;
                }
                
                c = (char) (ch | 0x20);
                if (c >= 'a' && c <= 'f') {
                    ch = (char) ((decoded << 4) + c - 'a' + 10);
                    
                    if (type & NGX_UNESCAPE_URI) {
                        if (ch == '?') {
                            *d++ = ch;
                            goto done;
                        }
                        
                        *d++ = ch;
                        break;
                    }
                    
                    if (type & NGX_UNESCAPE_REDIRECT) {
                        if (ch == '?') {
                            *d++ = ch;
                            goto done;
                        }
                        
                        if (ch > '%' && ch < 0x7f) {
                            *d++ = ch;
                            break;
                        }
                        
                        *d++ = '%'; *d++ = *(s - 2); *d++ = *(s - 1);
                        break;
                    }
                    
                    *d++ = ch;
                    
                    break;
                }
                
                /* the invalid quoted character */
                
                break;
		}
	}
    
done:
    
	*dst = d;
	*src = s;
}
int authen_augeoidfc(ngx_str_t url,ngx_str_t pri_key,char *rkey/*,ngx_http_request_t *r*/)  //authen_ex
{
    //this function can use¡¡hmac(sha1) to encrypt url,the private key is pri_key,the if the result equals
	//the authentication is successful! The return value mark the result ,success:1,failed:0.
	//attention please!In the url, the appid should be at its full length!!!So I still need to write a url generation function.
//	int flag = 0;//mark the authentication result,default :failed.
	unsigned char url_h[40];//wikipedia says this would be the length , see hamc.This is the space to store the hmac result. ÓÃÀŽŽæŽ¢¹þÏ£œá¹û
	unsigned char * p;
    unsigned char url_ht[45] = {0};
	size_t url_hmac_len;
    p = HMAC(EVP_sha1(), (const void *)pri_key.data, (int)pri_key.len, (const unsigned char *)url.data, url.len, url_h, (unsigned int *)&url_hmac_len);
//	p =  HMAC(EVP_sha1(),pri_key.data,pri_key.len,url.data,url.len,url_h,(unsigned int *)&url_hmac_len);
    strncpy((char *)url_ht, (const char *)url_h,url_hmac_len>40?40:url_hmac_len);
	if(p == NULL)
	{
		printf("HMAC ERROR!\n");
		return 0;
	}
	ngx_str_t url_hmac;
	url_hmac.data = (char *)url_h;
	url_hmac.len = url_hmac_len;	ngx_str_t url_hmac_base64;
    
	url_hmac_base64.data = (char *)php_base64_encode(url_hmac);//result is a string end with '\0'
	if(url_hmac_base64.data == NULL)
	{
		printf( "Base64 error!.\n");
		return 0;
	}

	strcpy(rkey,url_hmac_base64.data);
	free(url_hmac_base64.data);
	return 0;
}

void encode(char *public_key, char *private_key, char *rkey)
{
//    printf("url: %s\nkey: %s\n", public_key, private_key);
	ngx_str_t url,pri_key;
	
	url.data = public_key;
	url.len = strlen(public_key);
	
	pri_key.data = private_key;
	pri_key.len = strlen(private_key);
	
	authen_augeoidfc(url,pri_key,rkey);
}
void test()
{
//  strcpy(cKeyVal,"doMIwSLtisVFvJWz2j9V7Rj5d5c%3D");
    char *public_key = "http://geo.weather.com.cn/al1/?lon=132.23&lat=34.17&date=201407181129&appid=f573587ae1f343c5";
    char *private_key = "chinaweather_geo_data";
    char *rkey =  calloc(50,sizeof(char));
    
    encode(public_key,private_key,rkey);
    printf("encode 返回：\n");
    printf("key: %s\n", rkey);
    free(rkey);
}
