//
//  Shell.m
//  Utils
//
//  Created by wayos-ios on 10/13/14.
//  Copyright (c) 2014 webuser. All rights reserved.
//

#import "Shell.h"
#import <sys/sysctl.h>
#import <dirent.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import "NetUtils.h"
//cpu
#import <mach/mach_host.h>
#import <mach/task.h>
//内存
#import <sys/mount.h>

@implementation Shell
+ (NSArray *)ls{
    return [self ls:[self pwd]];
}

+ (NSArray *)ls:(NSString *)path{//只能ls目录, 文件还没做.todo
    NSAssert(path.length > 0, @"路径为空");
    DIR *dirp = opendir(path.UTF8String);
    if (dirp == NULL) {
        perror("ls出错");
//        closedir(dirp);
        return nil;
    }
    struct dirent *dp = NULL;
    NSMutableArray *ps = [NSMutableArray array];
    while ((dp = readdir(dirp)) != NULL) {//线程安全readdir_r
        //读取文件权限
        NSString *filePath = [NSString stringWithFormat:@"%@/%s",path,dp->d_name];
        struct stat fileStat;
        stat(filePath.UTF8String, &fileStat);
        if (dp->d_type == 4) {//目录
            [ps addObject:[NSString stringWithFormat:@"%s/,%o,%u",dp->d_name,fileStat.st_mode%01000,fileStat.st_uid]];
        }else{
            [ps addObject:[NSString stringWithFormat:@"%s,%lld,%o,%u",dp->d_name,fileStat.st_size,fileStat.st_mode%01000,fileStat.st_uid]];
        }

    }
    closedir(dirp);
    return ps;
}

+ (NSString *)pwd{
    char *buf = malloc(100);
    getcwd(buf, 101);
    NSString *pwd = [NSString stringWithUTF8String:buf];
    free(buf);
    return pwd;
}

+ (NSString *) cat:(NSString *)file{
    NSAssert(file.length > 0, @"为空");
    int fd = open(file.UTF8String, O_RDONLY);
    NSLog(@"open的文件描述符是: %d",fd);
    NSAssert(fd != -1, @"打开失败");
    long num = 0;
    NSMutableString *content = [NSMutableString string];
    do {
        char buf[200] = {0};
        num = read(fd, buf, 128);
        [content appendString:[NSString stringWithFormat:@"%s",buf]];
    } while (num == 128);
    close(fd);
    return content;
}

+ (BOOL) cd:(NSString *)path{
    NSAssert(path.length > 0, @"空");
    if( chdir(path.UTF8String) == 0){
        return YES;
    }else{
        perror("cd出错");
        return  NO;//真机被阉割
    }
}

+ (NSArray *)ps{
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size;
    sysctl(mib, 4, NULL, &size, NULL, 0);
    NSLog(@"stsctl返回长度, %zd",size);
    struct kinfo_proc * process = malloc(size);
    
    sysctl(mib, 4, process, &size, NULL, 0);
    NSLog(@"stsctl返回长度, %zd",size);
    NSAssert(size % sizeof(struct kinfo_proc) == 0, @"sysctl出错, 获取size出错 ");
    
    size_t nprocess = size / sizeof(struct kinfo_proc);
    NSAssert(nprocess > 0, @"没有进程");
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0; i < nprocess; i++){
        NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
        NSString * processName = [[NSString alloc] initWithUTF8String: process[i].kp_proc.p_comm];
        
        NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                            forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
        
        [array addObject:dict];
    }
    free(process);
    return array;
}

+ (BOOL) mkdir:(NSString *)path{
    NSAssert(path.length > 0, @"路径为空");
    if (mkdir(path.UTF8String, 0777) == 0) {
        return YES;
    }else{
        perror("mkdir出错");
        return  NO;
    }
}

+ (BOOL) rmdir:(NSString *)path{
    
    if(rmdir(path.UTF8String) == 0){
        return YES;
    }else{
        perror("rmdir出错");
        return  NO;
    }
}

+ (BOOL) chmod:(NSString *)file{
    if (chmod(file.UTF8String, 0777) == 0) {
        return YES;
    }else{
        perror("chmod出错");
        return NO;
    }
}

+ (NSString *)uname{
     struct utsname name;
    uname(&name);
    return [NSString stringWithFormat:@"%s,%s,%s,%s,%s",name.sysname,name.nodename,name.release,name.version,name.machine];
}

+ (void) test{
    perror("失败");
}

+ (BOOL) touch:(NSString *)file{
    NSAssert(file.length > 0, @"为空");
    int fd = open(file.UTF8String, O_CREAT|O_EXCL|O_WRONLY,0777);
    if (fd == -1) {
        perror("touch失败");
        close(fd);
        return NO;
    }else{
        write(fd, "", 0);
        close(fd);
        return YES;
    }

}

+ (BOOL) writeTo:(NSString *)path content:(NSString *)content{
    NSAssert(path.length > 0 && content.length > 0, @"为空");
    int fd = open(path.UTF8String, O_CREAT|O_EXCL|O_WRONLY,0777);
    if (fd == -1) {
        perror("write失败");
        close(fd);
        return NO;
    }else{
        write(fd, content.UTF8String, content.length);
        close(fd);
        return YES;
    }
}

+ (BOOL) rm:(NSString *)file{
    NSAssert(file.length > 0, @"空");
    if (remove(file.UTF8String) == -1) {
        perror("rm失败");
        return NO;
    }else{
        return YES;
    }
}

+ (NSString *)exec:(NSString *)commond{
    commond = [NSString stringWithFormat:@"%@ > /tmp/b",commond];
    NSLog(@"执行: %@",commond);
    int result = system(commond.UTF8String);
    int result2 = WIFEXITED(result);//判断commonmd是否执行成功
    int result3 = WEXITSTATUS(result);
    NSLog(@"执行结果%d,%d,%d",result,result2,result3);
    if(result >= 0 && result2 != 0 && result3 == 0){//有权限, 执行没错, 返回值没错(如果无权限, 那么result3返回127.126等)
        usleep(100000);//system是fork子进程最好等待一下再来
        NSString *str = [self cat:@"/tmp/b"];
        [self rm:@"/tmp/b"];
        return str;
    }else{
        return nil;
    }
}

+ (BOOL) ping:(NSString *)ip{
    NSAssert(ip.length > 0, @"ip空");
    return [NetUtils ping:ip];
}

+ (NSArray *)arp{
    return [NetUtils arpTable];
}

+ (NSString *)df{
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/tmp" error: nil];
    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
    NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
    return [NSString stringWithFormat:@"Memory Capacity of %f GB with %f GB Free memory available.",
            [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f,
            [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f];
}

+(NSString *)top{
    //获取cpu使用情况,http://www.cocoachina.com/bbs/read.php?tid=219455
    processor_cpu_load_info_t cpuLoad;
    mach_msg_type_number_t msgCount;
    natural_t count;
    host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &count, (processor_info_array_t *)&cpuLoad, &msgCount);
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"cpu个数%u",count];
    //内存情况
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    NSAssert(kernReturn == KERN_SUCCESS, @"去内存失败");
    [result appendFormat:@"free: %u\nactive: %u\ninactive: %u\nwire: %u\nzero fill: %u\nreactivations: %u\npageins: %u\npageouts: %u\nfaults: %u\ncow_faults: %u\nlookups: %u\nhits: %u",
          vmStats.free_count * vm_page_size,
          vmStats.active_count * vm_page_size,
          vmStats.inactive_count * vm_page_size,
          vmStats.wire_count * vm_page_size,
          vmStats.zero_fill_count * vm_page_size,
          vmStats.reactivations * vm_page_size,
          vmStats.pageins * vm_page_size,
          vmStats.pageouts * vm_page_size,
          vmStats.faults,
          vmStats.cow_faults,
          vmStats.lookups,
          vmStats.hits
    ];
    
    task_basic_info_data_t taskInfo;
    infoCount = TASK_BASIC_INFO_COUNT;
    kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    [result appendFormat:@"virtual_size:%u,resident_size:%u",taskInfo.virtual_size,taskInfo.resident_size];
    struct statfs buf;
    if(statfs("/", &buf) >= 0){
        [result appendFormat:@"磁盘类型:总大小,%dM,可用的, %dM",(int)(buf.f_bsize * buf.f_blocks/1024/1024),(int)(buf.f_bsize * buf.f_bfree/1024/1024)];
    }
    
    return result;
}
+(NSString *)route{
    return [NetUtils gateway2];
}
@end
