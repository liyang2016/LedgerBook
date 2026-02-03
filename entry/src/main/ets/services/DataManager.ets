import preferences from '@ohos.data.preferences'
import { BusinessError } from '@ohos.base'

export interface Transaction {
  id: number
  title: string
  amount: number
  type: 'income' | 'expense'
  date: string
  category: string
}

export interface Category {
  name: string
  icon: string
  type: 'income' | 'expense'
}

export interface BalanceSummary {
  balance: number
  totalIncome: number
  totalExpense: number
}

export class DataManager {
  private static instance: DataManager
  private preferencesStore: preferences.Preferences | null = null
  private readonly STORE_NAME = 'LedgerBookStore'
  private readonly KEY_TRANSACTIONS = 'transactions'
  private readonly KEY_CATEGORIES = 'categories'

  private constructor() {}

  public static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager()
    }
    return DataManager.instance
  }

  public async init(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.STORE_NAME)
    } catch (err) {
      let error = err as BusinessError
      console.error(`Failed to get preferences. Code: ${error.code}, message: ${error.message}`)
    }
  }

  public async getTransactions(): Promise<Transaction[]> {
    if (!this.preferencesStore) {
      return []
    }
    try {
      const data = await this.preferencesStore.get(this.KEY_TRANSACTIONS, '[]')
      return JSON.parse(data as string) as Transaction[]
    } catch (err) {
      let error = err as BusinessError
      console.error(`Failed to get transactions. Code: ${error.code}, message: ${error.message}`)
      return []
    }
  }

  public async saveTransactions(transactions: Transaction[]): Promise<boolean> {
    if (!this.preferencesStore) {
      return false
    }
    try {
      await this.preferencesStore.put(this.KEY_TRANSACTIONS, JSON.stringify(transactions))
      await this.preferencesStore.flush()
      return true
    } catch (err) {
      let error = err as BusinessError
      console.error(`Failed to save transactions. Code: ${error.code}, message: ${error.message}`)
      return false
    }
  }

  public async addTransaction(transaction: Transaction): Promise<boolean> {
    const transactions = await this.getTransactions()
    transactions.unshift(transaction)
    return await this.saveTransactions(transactions)
  }

  public async updateTransaction(transaction: Transaction): Promise<boolean> {
    const transactions = await this.getTransactions()
    const index = transactions.findIndex(t => t.id === transaction.id)
    if (index !== -1) {
      transactions[index] = transaction
      return await this.saveTransactions(transactions)
    }
    return false
  }

  public async deleteTransaction(id: number): Promise<boolean> {
    const transactions = await this.getTransactions()
    const filteredTransactions = transactions.filter(t => t.id !== id)
    return await this.saveTransactions(filteredTransactions)
  }

  public async getCategories(): Promise<Category[]> {
    if (!this.preferencesStore) {
      return this.getDefaultCategories()
    }
    try {
      const data = await this.preferencesStore.get(this.KEY_CATEGORIES, '')
      if (data && data !== '') {
        return JSON.parse(data as string) as Category[]
      }
      return this.getDefaultCategories()
    } catch (err) {
      let error = err as BusinessError
      console.error(`Failed to get categories. Code: ${error.code}, message: ${error.message}`)
      return this.getDefaultCategories()
    }
  }

  public async saveCategories(categories: Category[]): Promise<boolean> {
    if (!this.preferencesStore) {
      return false
    }
    try {
      await this.preferencesStore.put(this.KEY_CATEGORIES, JSON.stringify(categories))
      await this.preferencesStore.flush()
      return true
    } catch (err) {
      let error = err as BusinessError
      console.error(`Failed to save categories. Code: ${error.code}, message: ${error.message}`)
      return false
    }
  }

  private getDefaultCategories(): Category[] {
    return [
      { name: '餐饮', icon: '🍔', type: 'expense' },
      { name: '交通', icon: '🚗', type: 'expense' },
      { name: '购物', icon: '🛒', type: 'expense' },
      { name: '娱乐', icon: '🎮', type: 'expense' },
      { name: '医疗', icon: '💊', type: 'expense' },
      { name: '教育', icon: '📚', type: 'expense' },
      { name: '住房', icon: '🏠', type: 'expense' },
      { name: '工资', icon: '💰', type: 'income' },
      { name: '奖金', icon: '🎁', type: 'income' },
      { name: '投资', icon: '📈', type: 'income' },
      { name: '兼职', icon: '💼', type: 'income' }
    ]
  }

  public async calculateBalance(): Promise<BalanceSummary> {
    const transactions = await this.getTransactions()
    let totalIncome = 0
    let totalExpense = 0

    transactions.forEach(transaction => {
      if (transaction.type === 'income') {
        totalIncome += transaction.amount
      } else {
        totalExpense += transaction.amount
      }
    })

    return {
      balance: totalIncome - totalExpense,
      totalIncome,
      totalExpense
    } as BalanceSummary
  }
}
