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
@class ConfigurationWindowController;
@class Configuration;

@interface ExportWindowController : NSWindowController {

	Context *context;
	Configuration *configuration;
	ConfigurationWindowController *configurationWindowController;
	
	NSFileManager *filemgr;
	IBOutlet NSTextField *exportPath;
	IBOutlet NSTextField *exportFileName;

}


- (id) initWithContext:(Context *)contextObject;
- (IBAction) generatePackage:(id)sender;
- (IBAction) terminateApp:(id)sender;
- (IBAction) backConfigurationWindow:(id)sender;
- (IBAction) chooseExportPath:(id)sender;
- (BOOL) removeFile:(NSString *)path;


@end
