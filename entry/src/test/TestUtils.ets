/**
 * HarmonyOS 测试工具库
 * 基于华为官方测试规范实现
 */

import { describe, it, expect, beforeEach, afterEach } from '@ohos/hypium';

/**
 * Mock 函数类型
 */
export type MockFunction = {
  (...args: any[]): any;
  calls: any[][];
  returnValues: any[];
  mockImplementation: (impl: (...args: any[]) => any) => MockFunction;
  mockReturnValue: (value: any) => MockFunction;
  mockResolvedValue: (value: any) => MockFunction;
  mockRejectedValue: (value: any) => MockFunction;
  clear: () => void;
};

/**
 * 创建 Mock 函数
 * @returns MockFunction
 */
export function createMock(): MockFunction {
  const calls: any[][] = [];
  const returnValues: any[] = [];
  let implementation: (...args: any[]) => any = () => undefined;

  const mockFn: MockFunction = (...args: any[]) => {
    calls.push(args);
    const result = implementation(...args);
    returnValues.push(result);
    return result;
  };

  mockFn.calls = calls;
  mockFn.returnValues = returnValues;
  
  mockFn.mockImplementation = (impl: (...args: any[]) => any) => {
    implementation = impl;
    return mockFn;
  };

  mockFn.mockReturnValue = (value: any) => {
    implementation = () => value;
    return mockFn;
  };

  mockFn.mockResolvedValue = (value: any) => {
    implementation = () => Promise.resolve(value);
    return mockFn;
  };

  mockFn.mockRejectedValue = (value: any) => {
    implementation = () => Promise.reject(value);
    return mockFn;
  };

  mockFn.clear = () => {
    calls.length = 0;
    returnValues.length = 0;
  };

  return mockFn;
}

/**
 * Spy 包装器
 * 用于监视真实函数调用
 */
export type SpyFunction = {
  (...args: any[]): any;
  calls: any[][];
  returnValues: any[];
  original: (...args: any[]) => any;
  restore: () => void;
  clear: () => void;
};

/**
 * 创建 Spy 包装
 * @param obj 对象
 * @param method 方法名
 * @returns SpyFunction
 */
export function createSpy(obj: any, method: string): SpyFunction {
  const original = obj[method];
  const calls: any[][] = [];
  const returnValues: any[] = [];

  const spyFn: SpyFunction = (...args: any[]) => {
    calls.push(args);
    const result = original.apply(obj, args);
    returnValues.push(result);
    return result;
  };

  spyFn.calls = calls;
  spyFn.returnValues = returnValues;
  spyFn.original = original;

  spyFn.restore = () => {
    obj[method] = original;
  };

  spyFn.clear = () => {
    calls.length = 0;
    returnValues.length = 0;
  };

  // 替换原始方法
  obj[method] = spyFn;

  return spyFn;
}

/**
 * 性能测试装饰器
 * 记录函数执行时间
 */
export function measurePerformance<T extends (...args: any[]) => any>(
  fn: T,
  threshold: number = 1000
): { fn: T; duration: number; passed: boolean } {
  let duration = 0;
  let passed = false;

  const wrappedFn = (...args: Parameters<T>): ReturnType<T> => {
    const start = Date.now();
    const result = fn(...args);
    
    if (result instanceof Promise) {
      return result.then((res: any) => {
        duration = Date.now() - start;
        passed = duration < threshold;
        return res;
      }) as ReturnType<T>;
    } else {
      duration = Date.now() - start;
      passed = duration < threshold;
      return result;
    }
  } as T;

  return {
    fn: wrappedFn,
    get duration() { return duration; },
    get passed() { return passed; }
  } as any;
}

/**
 * 测试数据生成器
 * 用于生成测试用的交易数据
 */
export class TestDataGenerator {
  private static idCounter = 1;

  static reset(): void {
    this.idCounter = 1;
  }

  static generateId(): number {
    return Date.now() + this.idCounter++;
  }

  static createTransaction(overrides: any = {}): any {
    return {
      id: this.generateId(),
      title: overrides.title || '测试交易',
      amount: overrides.amount || 100,
      type: overrides.type || 'expense',
      date: overrides.date || '2026-02-03',
      category: overrides.category || '餐饮',
      ...overrides
    };
  }

  static createTransactions(count: number, overrides: any = {}): any[] {
    return Array.from({ length: count }, (_, i) => 
      this.createTransaction({
        title: `交易${i + 1}`,
        amount: (i + 1) * 10,
        ...overrides
      })
    );
  }
}

/**
 * 测试环境设置工具
 */
export class TestEnvironment {
  private static originalConsole: any;
  private static logs: string[] = [];

  static setup(): void {
    // 保存原始 console
    this.originalConsole = {
      log: console.log,
      info: console.info,
      warn: console.warn,
      error: console.error
    };

    // 替换为收集版本
    console.log = (...args: any[]) => {
      this.logs.push(`[LOG] ${args.join(' ')}`);
    };
    console.info = (...args: any[]) => {
      this.logs.push(`[INFO] ${args.join(' ')}`);
    };
    console.warn = (...args: any[]) => {
      this.logs.push(`[WARN] ${args.join(' ')}`);
    };
    console.error = (...args: any[]) => {
      this.logs.push(`[ERROR] ${args.join(' ')}`);
    };
  }

  static teardown(): void {
    // 恢复原始 console
    if (this.originalConsole) {
      console.log = this.originalConsole.log;
      console.info = this.originalConsole.info;
      console.warn = this.originalConsole.warn;
      console.error = this.originalConsole.error;
    }
    this.logs = [];
  }

  static getLogs(): string[] {
    return [...this.logs];
  }

  static clearLogs(): void {
    this.logs = [];
  }
}

/**
 * 异步测试助手
 * 处理异步操作的测试
 */
export class AsyncTestHelper {
  /**
   * 等待指定时间
   * @param ms 毫秒
   */
  static async wait(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 等待条件满足
   * @param condition 条件函数
   * @param timeout 超时时间
   * @param interval 检查间隔
   */
  static async waitFor(
    condition: () => boolean,
    timeout: number = 5000,
    interval: number = 100
  ): Promise<void> {
    const startTime = Date.now();
    while (!condition()) {
      if (Date.now() - startTime > timeout) {
        throw new Error('Wait timeout');
      }
      await this.wait(interval);
    }
  }
}

/**
 * 断言增强工具
 * 扩展 Hypium 的断言功能
 */
export class AssertEnhancer {
  /**
   * 验证数组包含指定元素
   */
  static assertArrayContains<T>(array: T[], item: T, message?: string): void {
    const contains = array.some(element => JSON.stringify(element) === JSON.stringify(item));
    if (!contains) {
      throw new Error(message || `Expected array to contain ${JSON.stringify(item)}`);
    }
  }

  /**
   * 验证对象包含指定属性
   */
  static assertObjectHasProperty(obj: any, property: string, message?: string): void {
    if (!(property in obj)) {
      throw new Error(message || `Expected object to have property ${property}`);
    }
  }

  /**
   * 验证日期有效性
   */
  static assertValidDate(dateStr: string, message?: string): void {
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) {
      throw new Error(message || `Invalid date string: ${dateStr}`);
    }
  }

  /**
   * 验证金额格式（2位小数）
   */
  static assertValidAmount(amount: number, message?: string): void {
    if (typeof amount !== 'number' || amount < 0) {
      throw new Error(message || `Invalid amount: ${amount}`);
    }
    const decimalPlaces = (amount.toString().split('.')[1] || '').length;
    if (decimalPlaces > 2) {
      throw new Error(message || `Amount should have at most 2 decimal places: ${amount}`);
    }
  }

  /**
   * 验证字符串长度
   */
  static assertStringLength(str: string, min: number, max: number, message?: string): void {
    if (str.length < min || str.length > max) {
      throw new Error(message || `String length should be between ${min} and ${max}`);
    }
  }
}

/**
 * 测试套件组织工具
 * 用于组织相关测试
 */
export function createTestSuite(
  name: string,
  setup?: () => void | Promise<void>,
  teardown?: () => void | Promise<void>
): {
  describe: (description: string, fn: () => void) => void;
  beforeAll: (fn: () => void | Promise<void>) => void;
  afterAll: (fn: () => void | Promise<void>) => void;
} {
  let beforeAllFn: (() => void | Promise<void>) | null = null;
  let afterAllFn: (() => void | Promise<void>) | null = null;

  return {
    describe: (description: string, fn: () => void) => {
      describe(`${name} - ${description}`, () => {
        beforeAll(() => {
          if (beforeAllFn) {
            const result = beforeAllFn();
            if (result instanceof Promise) {
              return result;
            }
          }
        });

        afterAll(() => {
          if (afterAllFn) {
            const result = afterAllFn();
            if (result instanceof Promise) {
              return result;
            }
          }
        });

        fn();
      });
    },
    beforeAll: (fn: () => void | Promise<void>) => {
      beforeAllFn = fn;
    },
    afterAll: (fn: () => void | Promise<void>) => {
      afterAllFn = fn;
    }
  };
}

export default {
  createMock,
  createSpy,
  measurePerformance,
  TestDataGenerator,
  TestEnvironment,
  AsyncTestHelper,
  AssertEnhancer,
  createTestSuite
};
