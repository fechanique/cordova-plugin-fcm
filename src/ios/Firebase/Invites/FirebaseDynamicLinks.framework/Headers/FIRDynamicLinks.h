#import <Foundation/Foundation.h>

#import "FIRDynamicLink.h"
#import "FIRDynamicLinksCommon.h"
#import "FIRDynamicLinksSwiftNameSupport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @file FIRDynamicLinks.h
 * @abstract Firebase Dynamic Links
 */

/**
 * @class FIRDynamicLinks
 * @abstract A class that checks for pending Dynamic Links and parses URLs.
 */
FIR_SWIFT_NAME(DynamicLinks)
@interface FIRDynamicLinks : NSObject

/**
 * @method dynamicLinks
 * @abstract Shared instance of FIRDynamicLinks. Returns nil on iOS versions prior to 8.
 * @return Shared instance of FIRDynamicLinks.
 */
+ (nullable instancetype)dynamicLinks FIR_SWIFT_NAME(dynamicLinks());

/**
 * @method shouldHandleDynamicLinkFromCustomSchemeURL:
 * @abstract Determine whether FIRDynamicLinks should handle the given URL. This does not
 *     guarantee that |dynamicLinkFromCustomSchemeURL:| will return a non-nil value, but it means
 *     the client should not attempt to handle the URL.
 * @param url Custom scheme URL.
 * @return Whether the URL can be handled by FIRDynamicLinks.
 */
- (BOOL)shouldHandleDynamicLinkFromCustomSchemeURL:(NSURL *)url
    FIR_SWIFT_NAME(shouldHandleDynamicLink(fromCustomSchemeURL:));

/**
 * @method dynamicLinkFromCustomSchemeURL:
 * @abstract Get a Dynamic Link from a custom scheme URL. This method parses URLs with a custom
 *     scheme, for instance, "comgoogleapp://google/link?deep_link_id=abc123". It is suggested to
 *     call it inside your |UIApplicationDelegate|'s
 *     |application:openURL:sourceApplication:annotation| and |application:openURL:options:|
 *     methods.
 * @param url Custom scheme URL.
 * @return Dynamic Link object if the URL is valid and has link parameter, otherwise nil.
 */
- (nullable FIRDynamicLink *)dynamicLinkFromCustomSchemeURL:(NSURL *)url
    FIR_SWIFT_NAME(dynamicLink(fromCustomSchemeURL:));

/**
 * @method dynamicLinkFromUniversalLinkURL:
 * @abstract Get a Dynamic Link from a universal link URL. This method parses universal link
 *     URLs, for instance,
 *     "https://example.app.goo.gl?link=https://www.google.com&ibi=com.google.app&ius=comgoogleapp".
 *     It is suggested to call it inside your |UIApplicationDelegate|'s
 *     |application:continueUserActivity:restorationHandler:| method.
 * @param url Custom scheme URL.
 * @return Dynamic Link object if the URL is valid and has link parameter, otherwise nil.
 */
- (nullable FIRDynamicLink *)dynamicLinkFromUniversalLinkURL:(NSURL *)url
    FIR_SWIFT_NAME(dynamicLink(fromUniversalLink:));

/**
 * @method handleUniversalLink:completion:
 * @abstract Convenience method to handle a Universal Link whether it is long or short. A long link
 *     will call the handler immediately, but a short link may not.
 * @param url A Universal Link URL.
 * @param completion A block that handles the outcome of attempting to create a FIRDynamicLink.
 * @return YES if FIRDynamicLinks is handling the link, otherwise, NO.
 */
- (BOOL)handleUniversalLink:(NSURL *)url
                 completion:(FIRDynamicLinkUniversalLinkHandler)completion;

/**
 * @method resolveShortLink:completion:linkResolver:
 * @abstract Retrieves the details of the Dynamic Link that the shortened URL represents.
 * @param url A Short Dynamic Link.
 * @param completion Block to be run upon completion.
 */
- (void)resolveShortLink:(NSURL *)url
              completion:(FIRDynamicLinkResolverHandler)completion;

/**
 * @method matchesShortLinkFormat:
 * @abstract Determines if a given URL matches the given short Dynamic Link format.
 * @param url A URL.
 * @return YES if the URL is a short Dynamic Link, otherwise, NO.
 */
- (BOOL)matchesShortLinkFormat:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
