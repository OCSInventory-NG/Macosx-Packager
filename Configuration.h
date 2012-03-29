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
	NSString *launchdFilePath;
	NSString *nowFilePath;
	NSString *cfgFilePath;
	
	int debugmode;
	int download;
	int lazy;
	int startup;
	int now;

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

- (int) debugmode;
- (void) setDebugmode:(int)newDebugmode;

- (int) download;
- (void) setDownload:(int)newDownload;

- (int) lazy;
- (void) setLazy:(int)newLazy;

- (int) startup;
- (void) setStartup:(int)newStartup;

- (int) now;
- (void) setNow:(int)newNow;


@end
