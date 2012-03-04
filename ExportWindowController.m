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


#import "ExportWindowController.h"

#import "Context.h"
#import "ConfigurationWindowController.h"
#import "Configuration.h"


@implementation ExportWindowController


-(id) initWithContext:(Context *)contextObject {
	
	if (self = [super initWithWindowNibName:@"ExportWindow"]) {
		[context release];
		context = [contextObject retain];
		
		configuration = [context configuration];
		configurationWindowController = [context configurationWindowController];
		
		filemgr = [NSFileManager defaultManager];
		
	}
	return self;
	
}

- (IBAction) generatePackage:(id)sender {
	
	NSMutableString *ocsAgentCfgContent;
	NSMutableString *modulesCfgContent;
	NSMutableString *protocolName;
	NSMutableString *launchdCfgFile;
	NSString *serverDir;
	NSString *finalMessageComment;
	
	NSString *ocsPkgPath = [NSString stringWithFormat:@"%@/%@",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgPluginsPath = [NSString stringWithFormat:@"%@/%@/Contents/Plugins",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgResourcesPath = [NSString stringWithFormat:@"%@/%@/Contents/Resources",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgCfgFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/ocsinventory-agent.cfg",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgModulesFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/modules.conf",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgServerdirFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/serverdir",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgCacertFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/cacert.pem",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgLaunchdFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/org.ocsng.agent.plist",[exportPath stringValue],@"ocspackage.pkg"];
	NSString *ocsPkgNowFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/now",[exportPath stringValue],@"ocspackage.pkg"];

	//We check if ocspackage.pkg already exists
	if ([filemgr fileExistsAtPath:ocsPkgPath]) {
		NSAlert *existsWrn = [[NSAlert alloc] init];
		
		[existsWrn addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes Button")];
		[existsWrn addButtonWithTitle:NSLocalizedString(@"No", @"No Button")];
		[existsWrn setMessageText:NSLocalizedString(@"Ocspackage_already_exists_warn",@"Warning about already existing ocspackage file")];
		[existsWrn setInformativeText:NSLocalizedString(@"Ocspackage_already_exists_warn_comment",@"Warning about already existing ocspackage file comment")];
		[existsWrn setAlertStyle:NSCriticalAlertStyle]; 
		
		if ([existsWrn runModal] != NSAlertFirstButtonReturn) {
			//Button 'No' was clicked, we don't continue
			[existsWrn release];	
			return;
		} else {
			//We delete file
			[existsWrn release];
			if(![filemgr removeFileAtPath:ocsPkgPath handler:nil]) {
				[context displayAlert:NSLocalizedString(@"Ocspackage_remove_error_warn", @"Warning about ocspackage remove error") comment:NSLocalizedString(@"Ocspackage_remove_error_warn_comment",@"Warning about ocspackage remove error comment") style:NSCriticalAlertStyle];
				return;
			}
		}
	}
	
	//We create new ocspackage.pkg file
	if (![filemgr copyPath:[configuration ocsPkgFilePath] toPath:ocsPkgPath handler:nil]) {
		[context displayAlert:NSLocalizedString(@"Ocspackage_copy_error_warn", @"Warning about ocspackage copy error") comment:NSLocalizedString(@"Ocspackage_copy_error_warn_comment",@"Warning about ocspackage copy error comment") style:NSCriticalAlertStyle];
		return;
	}
	
	//We delete plugins directory for future silent installs
	if ([filemgr fileExistsAtPath:ocsPkgPluginsPath]) {
		if (![filemgr removeFileAtPath:ocsPkgPluginsPath handler:nil]) {
			[context displayAlert:NSLocalizedString(@"Plugins_remove_error_warn", @"Warning about plugins directory remove error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment",@"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
			return;
		}
	}
	
	//We copy preinstall script
	NSString *preinstallPath = [NSString stringWithFormat:@"%@/preinstall",[[NSBundle mainBundle] resourcePath]];
	
	if ([filemgr fileExistsAtPath:preinstallPath]) {
		if (![filemgr copyPath:preinstallPath toPath:[NSString stringWithFormat:@"%@/preinstall",ocsPkgResourcesPath] handler:nil]) {
			[context displayAlert:NSLocalizedString(@"Preinstall_copy_error_warn",@"Warning about preinstall copy error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
			return;
		}
	}
			
	//We create agent configuration files
	if ([[configuration server] length] > 0) {
		ocsAgentCfgContent = [@"server=" mutableCopy];
		
		//Adding server value to the mutable string
		[ocsAgentCfgContent appendString:[configuration protocol]];
		[ocsAgentCfgContent appendString:[configuration server]];
		[ocsAgentCfgContent appendString:@"/ocsinventory"];
		[ocsAgentCfgContent appendString:@"\n"];
	}
	
	if ([[configuration tag] length] > 0) {
		[ocsAgentCfgContent appendString:@"tag="];
		[ocsAgentCfgContent appendString:[configuration tag]];
		[ocsAgentCfgContent appendString:@"\n"];	
	}
	
	if ([[configuration logfile] length] > 0) {
		[ocsAgentCfgContent appendString:@"logfile="];
		[ocsAgentCfgContent appendString:[configuration logfile]];
		[ocsAgentCfgContent appendString:@"\n"];	
	}
	
	if ([configuration debugmode]) {
		[ocsAgentCfgContent appendString:@"debug=1\n"];
	}
	
	
	if(![ocsAgentCfgContent writeToFile:ocsPkgCfgFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
		[context displayAlert:NSLocalizedString(@"Configuration_file_write_error_warn",@"Warning about ocsinventory-agent.cfg file write error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
		return;
	}
	
	//We create modules configuration files
	modulesCfgContent = [@"# this list of module will be load by the at run time\n"
						 @"# to check its syntax do:\n"
						 @"# #perl modules.conf\n"
						 @"# You must have NO error. Else the content will be ignored\n"
						 @"# This mechanism goal it to keep compatibility with 'plugin'\n"
						 @"# created for the previous linux_agent.\n"
						 @"# The new unified_agent have its own extension system that allow\n"
						 @"# user to add new information easily.\n"
						 @"\n" 
						 @"#use Ocsinventory::Agent::Modules::Example;\n"
						 mutableCopy];
	
	if ( [configuration download] == 1) {
		[modulesCfgContent appendString:@"use Ocsinventory::Agent::Modules::Download;\n"];
	} else {
		[modulesCfgContent appendString:@"#use Ocsinventory::Agent::Modules::Download;\n"];
	}
	
	[modulesCfgContent appendString:@"\n"
									@"# DO NOT REMOVE THE 1;\n"
									@"1;"
									];
	
	if (![modulesCfgContent writeToFile:ocsPkgModulesFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
		[context displayAlert:NSLocalizedString(@"Modules_file_write_error_warn",@"Warning about modules.conf file write error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
		return;
	}
	
	
	//We copy cacertfile and create file for server directory creation
	if ([[configuration cacertFilePath] length] > 0) {
		
		protocolName = [[configuration protocol] mutableCopy];
		[protocolName replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [protocolName length])];
		
		serverDir = [NSString stringWithFormat:@"/var/lib/ocsinventory-agent/%@__%@_ocsinventory", protocolName, [configuration server]];
		[serverDir writeToFile:ocsPkgServerdirFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL];
		
		if (![filemgr copyPath:[configuration cacertFilePath] toPath:ocsPkgCacertFilePath handler:nil]) {
			[context displayAlert:NSLocalizedString(@"Cacert_file_copy_error_warn",@"Warning about cacert.pem file copy error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
			return;
		}
	}
	
	
	//We create launchd configuration file
	//TODO: use XML parser instead of writing the XML as a simple text file ?
	launchdCfgFile = [@"<?xml version='1.0' encoding='UTF-8'?>\n"
					  @"<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>\n"
					  @"<plist version='1.0'>\n"
					  @"<dict>\n"
					  @"\t<key>Label</key>\n"
					  @"\t<string>org.ocsng.agent</string>\n"
					  @"\t<key>ProgramArguments</key>\n"
					  @"\t\t<array>\n"
					  @"\t\t\t<string>/Applications/OCSNG.app/Contents/MacOS/OCSNG</string>\n"
					  @"\t\t</array>\n"
					  mutableCopy];	
	
	
	if ([configuration startup] == 1) {
		[launchdCfgFile  appendString:@"\t<key>RunAtLoad</key>\n"
		 @"\t<true/>\n"
		 ];
	}
	
	if ( [[configuration periodicity] length] > 0) {
		//We convert string to numeric value and check if it is integer
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		NSNumber *convert = [formatter numberFromString:[configuration periodicity]];
		[formatter release];
		
		if (convert) {
			int hours = [convert intValue];
			int seconds =  hours * 3600;
			
			[launchdCfgFile  appendString:@"\t<key>StartInterval</key>\n"
			 @"\t<integer>"
			 ];
			
			[launchdCfgFile  appendString:[NSString stringWithFormat:@"%d", seconds]];
			[launchdCfgFile  appendString:@"</integer>\n"];
			
		} else {
			//Invalid periodificty value
			[context displayAlert:NSLocalizedString(@"Periodicity_warn", @"Peridocity warn") comment:NSLocalizedString(@"Periodicity_warn_comment", @"Periodicity warn comment") style:NSCriticalAlertStyle];
			return;
		}
	}
	
	[launchdCfgFile appendString:@"</dict>\n"
								  @"</plist>"
								  ];
	
	if (![launchdCfgFile writeToFile:ocsPkgLaunchdFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
		[context displayAlert:NSLocalizedString(@"Launchd_file_write_error_warn",@"Warning about org.ocsng.agent.plit file write error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
		return;
	}
	
	
	//We create now file if needed
	if ([configuration now] == 1) {
		if (![filemgr createFileAtPath:ocsPkgNowFilePath contents:nil attributes:nil]) {
			[context displayAlert:NSLocalizedString(@"Now_file_write_error_warn",@"Warning about now file write error") comment:NSLocalizedString(@"Ocspackage_write_error_warn_comment", @"Warning about ocspackage write error comment") style:NSCriticalAlertStyle];
			return;
		}
	}

	
	//Everything OK and package generated succefully
	finalMessageComment = [NSString stringWithFormat:NSLocalizedString(@"Package_succesfully_created_comment",@"Message for succefull created package_comment"), [exportPath stringValue]];
	[context displayAlert:NSLocalizedString(@"Package_succesfully_created",@"Message for succefull created package") comment:finalMessageComment style:NSInformationalAlertStyle];
	[NSApp terminate:self];
}


//To quit application
- (IBAction) terminateApp:(id)sender {
	[NSApp terminate:self];
}

- (IBAction) backConfigurationWindow:(id)sender {
	
	[[configurationWindowController window] orderFront:sender];
	[[self window] orderOut:sender];
}

- (IBAction) chooseExportPath:(id)sender {
	
	//Configuration for the browse panel
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];

	
	//Running browse panel
	int result = [panel runModal];
	
	//Getting cacert file path
	if (result == NSOKButton) {
		[exportPath setStringValue:[panel filename]];
	}
}

//Famous dealloc for memory management
- (void) dealloc {
	[context release];
	[super dealloc];
	
}

@end
