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


#import "ConfigurationWindowController.h"

#import "Context.h"
#import "ExportWindowController.h"
#import "Configuration.h"

@implementation ConfigurationWindowController


//When nib is launched
- (void)awakeFromNib {
	
	//Create object for context
	if (!context) {
		context = [[Context alloc] init];
	}

	//We add ourself references in context
	[context setConfigurationWindowController:self];
	
	//Create object for storing configuration and its reference in context
	if (!configuration) {
		configuration = [[Configuration alloc] init];
	}
	[context setConfiguration:configuration];
	
	//Create object for second panel and add its reference in context
	if (!exportWindowController) {
		exportWindowController = [[ExportWindowController alloc] initWithContext:context];
	}
	[context setExportWindowController:exportWindowController];
	
	//Filling defaults values
	[userServer setStringValue:@"ocsinventory-ng"];
	[userLogFile setStringValue:@"/var/log/ocsng.log"];
	[userPeriodicity setStringValue:@"5"];
	[userDebugMode setState:1];
	[userDownload setState:1];
	[userLazy setState:0];
	[userStartup setState:1];
	[userNow setState:0];
	
	//Defaults for protocol droping list
	[protocolist removeAllItems];
	[protocolist addItemWithTitle: @"http://"];
	[protocolist addItemWithTitle: @"https://"];
	[protocolist selectItemWithTitle: @"http://"];
	
}



- (IBAction) chooseCacertFile:(id)sender {
	NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"pem",@"PEM",@"crt",@"CRT",nil];
	
	//Configuration for the browse panel
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setAllowedFileTypes:fileTypes];
	
	//Running browse panel
	NSInteger result = [panel runModal];
	
	//Getting cacert file path
	if (result == NSModalResponseOK) {
		[userCacertFile setStringValue:[[panel URL] path]];
	}
}

- (IBAction) chooseOcsPkgFile:(id)sender {
	
	NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"pkg",nil];
	
	//Configuration for the browse panel
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseDirectories:NO];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setAllowedFileTypes:fileTypes];
	
	//Running browse panel
	NSInteger result = [panel runModal];
	
	//Getting cacert file path
	if (result == NSModalResponseOK) {
		[userOcsPkgFile setStringValue:[[panel URL] path]];
	}
	
}


- (IBAction) chooseProtocol:(id)sender {
	NSString *protocol = [protocolist titleOfSelectedItem];
	
	//We show the selected protocol
	[protocolist setTitle:protocol];
}


- (NSArray *) protocols {
	return [NSArray arrayWithObjects:@"http", @"https", nil];
}


- (IBAction) getUserConfiguration:(id)sender {
	
	//No OCS pkg file path filled
	if ( !([[userOcsPkgFile stringValue] length] > 0 )) {
		[context displayAlert:NSLocalizedString(@"Invalid_pkg_file", @"Warning about invalid OCS package file") comment:NSLocalizedString(@"Invalid_pkg_file_comment", @"Warning about invalid OCS package comment") style:NSAlertStyleCritical];
		return;
	}
	
	//No OCS server address filled
	if ( !([[userServer stringValue] length] > 0 )) {
		[context displayAlert:NSLocalizedString(@"Invalid_srv_addr", @"Warning about invalid server address") comment:NSLocalizedString(@"Invalid_srv_addr_comment", @"Warning about invalid server address comment") style:NSAlertStyleCritical];
		return;
	}
	
	//Download feature activated but no cacert.pem file path filled
	if ( [userDownload state] == 1 && [[userCacertFile stringValue] length] == 0 ) {
		NSAlert *caCertWrn = [[NSAlert alloc] init];
		
		[caCertWrn addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes Button")];
		[caCertWrn addButtonWithTitle:NSLocalizedString(@"No", @"No Button")];
		[caCertWrn setMessageText:NSLocalizedString(@"Missing_cert_warn",@"Warning about missing certificate file")];
		[caCertWrn setInformativeText:NSLocalizedString(@"Missing_cert_warn_comment",@"Warning about missing certificate file comment")];
		[caCertWrn setAlertStyle:NSAlertStyleCritical];
		
		if ([caCertWrn runModal] != NSAlertFirstButtonReturn) {
			//Button 'No' was clicked, we don't continue
			[caCertWrn release];	
			return;
		}
		
		[caCertWrn release];
	}
    
	//No periodicity value filled
	if ( !([[userPeriodicity stringValue] length] > 0)) {
		[context displayAlert:NSLocalizedString(@"Periodicity_warn", @"Peridocity warn") comment:NSLocalizedString(@"Periodicity_warn_comment", @"Periodicity warn comment") style:NSAlertStyleCritical];
		return;
	}
	
	//Set configuration
	[configuration setOcsPkgFilePath:[userOcsPkgFile stringValue]];
	[configuration setProtocol:[protocolist titleOfSelectedItem]];
	[configuration setServer:[userServer stringValue]];
	[configuration setLogfile:[userLogFile stringValue]];
	[configuration setTag:[userTag stringValue]];
	[configuration setCacertFilePath:[userCacertFile stringValue]];
    
    [configuration setUser:[authUser stringValue]];
    [configuration setPwd:[authPwd stringValue]];
    [configuration setRealm:[authRealm stringValue]];
    
	[configuration setDebugmode:[userDebugMode state]];
	[configuration setDownload:[userDownload state]];
	[configuration setLazy:[userLazy state]];
	[configuration setPeriodicity:[userPeriodicity stringValue]];
	[configuration setStartup:[userStartup state]];
	[configuration setNow:[userNow state]]; 
	
	//We display the next window
	[self displayExportWindow];
	[[self window] orderOut:sender];
	
}

- (void) displayExportWindow {
	[exportWindowController showWindow:nil];
}


//To quit application
- (IBAction) terminateApp:(id)sender {
	[NSApp terminate:self];
}


//Famous dealloc for memory management
- (void) dealloc {

	[exportWindowController release];	
	[super dealloc];
	
}


@end
