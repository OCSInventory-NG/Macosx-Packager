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


#import "Context.h"
#import "ConfigurationWindowController.h"
#import "ExportWindowController.h"
#import "Configuration.h"


@implementation Context


- (ConfigurationWindowController *) configurationWindowController {
	return [[configurationWindowController retain] autorelease];
}

- (ExportWindowController *) exportWindowController {
	return [[exportWindowController retain] autorelease];
}

- (Configuration *) configuration {
	return [[configuration retain] autorelease];
}


- (void) setConfigurationWindowController:(ConfigurationWindowController *)object {
	if (configurationWindowController != object) {
		[configurationWindowController release];
		[object retain];
		configurationWindowController = object;
	}
}


- (void) setExportWindowController:(ExportWindowController *)object {
	if (exportWindowController != object) {
		[exportWindowController release];
		[object retain];
		exportWindowController = object;
	}
	
}

- (void) setConfiguration:(Configuration *)object {
	if (configuration != object) {
		[configuration release];
		[object retain];
		configuration = object;
	}
}

- (void) displayAlert:(NSString *)alertMessage comment:(NSString *)alertComment style:(NSAlertStyle)alertStyle {
	//Display a simple alert with an OK button
	NSAlert *alert = [[NSAlert alloc] init];
	
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:alertMessage];
	[alert setInformativeText:alertComment];
	[alert setAlertStyle:alertStyle];
	[alert runModal];
	[alert release];
}


//Famous dealloc for memory management
- (void) dealloc {
	
	[super dealloc];
	
}

@end
