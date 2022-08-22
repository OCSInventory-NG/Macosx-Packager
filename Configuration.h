////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// OCSINVENTORY-NG                                                                //
//                                                                                //
// Copyleft Guillaume PROTET 2012                                                 //
// Web : http://www.ocsinventory-ng.org                                           //
//                                                                                //
//                                                                                //
// This code is open source and may be copied and modified as long as the source  //
// code is always made freely available.                                          //
// Please refer to the General Public Licence http://www.gnu.org/                 //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>


@interface Configuration : NSObject {
    
    NSString *server;
    NSString *tag;
    NSString *logfile;
    NSString *protocol;
    NSString *periodicity;
    NSString *ocsPkgFilePath;
    NSString *modulesFilePath;
    NSString *serverdirFilePath;
    NSString *cacertFilePath;
    NSString *authUser;
    NSString *authPwd;
    NSString *authRealm;
    NSString *launchdFilePath;
    NSString *nowFilePath;
    NSString *cfgFilePath;
    
    NSInteger debugmode;
    NSInteger download;
    NSInteger lazy;
    NSInteger startup;
    NSInteger now;
    
    NSFileManager *filemgr;
    
}

//Accessors for variables
- (NSString *) server;
- (void) setServer:(NSString *)newServer;

- (NSString *) tag;
- (void) setTag:(NSString *)newTag;

- (NSString *) logfile;
- (void) setLogfile:(NSString *)newLogFile;

- (NSString *) protocol;
- (void) setProtocol:(NSString *)newProtocol;

- (NSString *) periodicity;
- (void) setPeriodicity:(NSString *)newPeriodicity;

- (NSString *) ocsPkgFilePath;
- (void) setOcsPkgFilePath:(NSString *)newPkgFilePath;;

- (NSString *) cacertFilePath;
- (void) setCacertFilePath:(NSString *)newCacertFilePath;

- (NSString *) authUser;
- (void) setUser:(NSString *)newAuthUser;

- (NSString *) authPwd;
- (void) setPwd:(NSString *)newAuthPwd;

- (NSString *) authRealm;
- (void) setRealm:(NSString *)newAuthRealm;

- (NSInteger) debugmode;
- (void) setDebugmode:(NSInteger)newDebugmode;

- (NSInteger) download;
- (void) setDownload:(NSInteger)newDownload;

- (NSInteger) lazy;
- (void) setLazy:(NSInteger)newLazy;

- (NSInteger) startup;
- (void) setStartup:(NSInteger)newStartup;

- (NSInteger) now;
- (void) setNow:(NSInteger)newNow;


@end
