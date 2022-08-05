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


#import "Configuration.h"


@implementation Configuration


//Accessors for server variable
- (NSString *) server {
	return [[server retain] autorelease];
}

- (void) setServer:(NSString *)newServer {
	if (server != newServer) {
		[server release];
		server = [newServer copy];
	}
}

//Accessors for tag variable
- (NSString *) tag {
	return [[tag retain] autorelease];
}

- (void) setTag:(NSString *)newTag {
	if (tag != newTag) {
		[tag release];
		tag = [newTag copy];
	}
}

//Accessors for logfile variable
- (NSString *) logfile {
	return [[logfile retain] autorelease];
}

- (void) setLogfile:(NSString *)newLogfile {
	if (logfile != newLogfile) {
		[logfile release];
		logfile = [newLogfile copy];
	}
}


//Accessors for protocol variable
- (NSString *) protocol {
	return [[protocol retain] autorelease];
}

- (void) setProtocol:(NSString *)newProtocol {
	if (protocol != newProtocol) {
		[protocol release];
		protocol = [newProtocol copy];
	}
}

//Accessors for periodicity variable
- (NSString *) periodicity {
	return [[periodicity retain] autorelease];
}

- (void) setPeriodicity:(NSString *)newPeriodicity {
	if (periodicity != newPeriodicity) {
		[periodicity release];
		periodicity = [newPeriodicity copy];
	}
}

//Accessors for ocsPkgFile variable
- (NSString *) ocsPkgFilePath {
	return [[ocsPkgFilePath retain] autorelease];
}

- (void) setOcsPkgFilePath:(NSString *)newOcsPkgFilePath {
	if (ocsPkgFilePath != newOcsPkgFilePath) {
		[ocsPkgFilePath release];
		ocsPkgFilePath = [newOcsPkgFilePath copy];
	}
}

//Accessors for cacertfile variable
- (NSString *) cacertFilePath {
	return [[cacertFilePath retain] autorelease];
}

- (void) setCacertFilePath:(NSString *)newCacertFilePath {
	if (cacertFilePath != newCacertFilePath) {
		[cacertFilePath release];
		cacertFilePath = [newCacertFilePath copy];
	}
}

//Accessors for authUser variable
- (NSString *) authUser {
    return [[authUser retain] autorelease];
}

- (void) setUser:(NSString *)newAuthUser {
    if (authUser != newAuthUser) {
        [authUser release];
        authUser = [newAuthUser copy];
    }
}

//Accessors for authPwd variable
- (NSString *) authPwd {
    return [[authPwd retain] autorelease];
}

- (void) setPwd:(NSString *)newAuthPwd {
    if (authPwd != newAuthPwd) {
        [authPwd release];
        authPwd = [newAuthPwd copy];
    }
}

//Accessors for authUser variable
- (NSString *) authRealm {
    return [[authRealm retain] autorelease];
}

- (void) setRealm:(NSString *)newAuthRealm {
    if (authRealm != newAuthRealm) {
        [authRealm release];
        authRealm = [newAuthRealm copy];
    }
}

//Accessors for debugmode variable
- (NSInteger) debugmode {
	return debugmode;
}

- (void) setDebugmode:(NSInteger)newDebugmode {
	if (debugmode != newDebugmode) {
		debugmode = newDebugmode;
	}
}

//Accessors for download variable
- (NSInteger) download {
	return download;
}

- (void) setDownload:(NSInteger)newDownload {
	if (download != newDownload) {
		download = newDownload;
	}
}

//Accessors for lazy variable
- (NSInteger) lazy {
	return lazy;
}

- (void) setLazy:(NSInteger)newLazy {
	if (lazy != newLazy) {
		lazy = newLazy;
	}
}

//Accessors for startup variable
- (NSInteger) startup {
	return startup;
}

- (void) setStartup:(NSInteger)newStartup {
	if (startup != newStartup) {
		startup = newStartup;
	}
}

//Accessors for now variable
- (NSInteger) now {
	return now;
}

- (void) setNow:(NSInteger)newNow {
	if (now != newNow) {
		now = newNow;
	}
}

//Famous dealloc for memory management
- (void) dealloc {
	
	[super dealloc];
	
}

@end
