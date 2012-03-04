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


@class ConfigurationWindowController;
@class ExportWindowController;
@class Configuration;

@interface Context : NSObject {

	ConfigurationWindowController *configurationWindowController;
	ExportWindowController *exportWindowController;
	Configuration *configuration;
	
}

- (ConfigurationWindowController *) configurationWindowController;
- (void) setConfigurationWindowController:(ConfigurationWindowController *)object;

- (ExportWindowController *) exportWindowController;
- (void) setExportWindowController:(ExportWindowController *)object;

- (Configuration *) configuration;
- (void) setConfiguration:(Configuration *)object;

- (void) displayAlert:(NSString *)alertMessage comment:(NSString *)alertComment style:(NSAlertStyle)alertStyle;

@end
