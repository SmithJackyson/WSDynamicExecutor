//
//  WSDynamicExecutorDefine.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/19.
//

#ifndef WSDynamicExecutorDefine_h
#define WSDynamicExecutorDefine_h

#define WSWeakify(object) \
    @try {} @finally {} \
    __weak typeof(object) weak##object = object;

#define WSStrongify(object) \
    @try {} @finally {} \
    __strong typeof(object) strong##object = weak##object; \
    if (!strong##object) { return; }

#endif /* WSDynamicExecutorDefine_h */
