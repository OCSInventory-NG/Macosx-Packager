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


@class Context;
@class ExportWindowController;
@class Configuration;

@interface ConfigurationWindowController : NSWindowController {

	IBOutlet NSTextField *userOcsPkgFile;
	IBOutlet NSTextField *userServer;
	IBOutlet NSTextField *userLogFile;
	IBOutlet NSTextField *userTag;
	IBOutlet NSTextField *userCacertFile;
    IBOutlet NSTextField *authUser;
    IBOutlet NSTextField *authPwd;
    IBOutlet NSTextField *authRealm;
	IBOutlet NSButton *userDebugMode;
	IBOutlet NSButton *userDownload;
	IBOutlet NSButton *userLazy;
	IBOutlet NSTextField *userPeriodicity;
	IBOutlet NSButton *userStartup;
	IBOutlet NSButton *userNow;

	IBOutlet NSPopUpButton *protocolist;
	
	ExportWindowController *exportWindowController;
	Context *context;
	Configuration *configuration;
	

}

- (IBAction) chooseCacertFile:(id)sender;
- (IBAction) chooseOcsPkgFile:(id)sender;
- (IBAction) chooseProtocol:(id)sender;
- (IBAction) getUserConfiguration:(id)sender;
- (void) displayExportWindow;
- (IBAction) terminateApp:(id)sender;


@end
