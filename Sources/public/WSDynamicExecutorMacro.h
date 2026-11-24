//
//  WSDynamicExecutorMacro.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/10.
//

#ifndef WSDynamicExecutorMacro_h
#define WSDynamicExecutorMacro_h

NS_ASSUME_NONNULL_BEGIN

#define WSString(string)    #string
#define WSExecOptions(...)  { __VA_ARGS__ }

#define WSRegisterExecutor(taskName, taskOptions) \
static void _ws_##taskName(WSExecutorContext context); \
__attribute__((used, section("__DATA,__ws_executors"))) \
static const WSExecutorDescriptor __descriptor_##taskName = { \
  .name = #taskName, \
  .options = taskOptions, \
  .executor = _ws_##taskName, \
}; \
static void _ws_##taskName(WSExecutorContext context) \

NS_ASSUME_NONNULL_END

#endif /* WSDynamicExecutorMacro_h */
