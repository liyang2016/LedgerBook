import { DataManager, Transaction, Category } from '../services/DataManager'

@CustomDialog
export struct AddTransactionDialog {
  private dataManager: DataManager = DataManager.getInstance()
  controller: CustomDialogController
  onTransactionAdded: () => void = () => {}

  @State transactionType: 'income' | 'expense' = 'expense'
  @State amount: string = ''
  @State title: string = ''
  @State selectedCategory: string = ''
  @State selectedDate: string = ''
  @State categories: Category[] = []
  @State showCategoryPicker: boolean = false

  async aboutToAppear(): Promise<void> {
    this.selectedDate = this.getCurrentDate()
    await this.filterCategoriesByType()
  }

  getCurrentDate(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  async filterCategoriesByType(): Promise<void> {
    const allCategories = await this.dataManager.getCategories()
    this.categories = allCategories.filter(cat => cat.type === this.transactionType)
    if (this.categories.length > 0 && !this.selectedCategory) {
      this.selectedCategory = this.categories[0].name
    }
  }

  async onTypeChange(type: 'income' | 'expense'): Promise<void> {
    this.transactionType = type
    await this.filterCategoriesByType()
  }

  async onSave(): Promise<void> {
    if (!this.amount || !this.title || !this.selectedCategory) {
      return
    }

    const transaction: Transaction = {
      id: Date.now(),
      title: this.title,
      amount: parseFloat(this.amount),
      type: this.transactionType,
      date: this.selectedDate,
      category: this.selectedCategory
    }

    const success = await this.dataManager.addTransaction(transaction)
    if (success) {
      this.controller.close()
      this.onTransactionAdded()
    }
  }

  build() {
    Column() {
      Row() {
        Text('添加账单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        Button() {
          Text('×')
            .fontSize(24)
            .fontColor('#757575')
        }
        .width(36)
        .height(36)
        .backgroundColor('#F0F0F0')
        .borderRadius(6)
        .onClick(() => {
          this.controller.close()
        })
      }
      .width('100%')
      .padding({ bottom: 24 })

      Column() {
        Text('账单类型')
          .fontSize(13)
          .fontColor('#757575')
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          Button(this.transactionType === 'expense' ? '支出' : '支出')
            .width('48%')
            .height(44)
            .backgroundColor(this.transactionType === 'expense' ? '#F44336' : '#F0F0F0')
            .fontColor(this.transactionType === 'expense' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(async () => {
              await this.onTypeChange('expense')
            })

          Button(this.transactionType === 'income' ? '收入' : '收入')
            .width('48%')
            .height(44)
            .backgroundColor(this.transactionType === 'income' ? '#4CAF50' : '#F0F0F0')
            .fontColor(this.transactionType === 'income' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(async () => {
              await this.onTypeChange('income')
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .margin({ bottom: 24 })

      Column() {
        Text('金额')
          .fontSize(13)
          .fontColor('#757575')
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          Text('¥')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ right: 8 })

          TextInput({ placeholder: '0.00', text: this.amount })
            .type(InputType.Number)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .backgroundColor('#F5F5F5')
            .borderRadius(6)
            .height(56)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.amount = value
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(6)
      }
      .width('100%')
      .margin({ bottom: 24 })

      Column() {
        Text('分类')
          .fontSize(13)
          .fontColor('#757575')
          .width('100%')
          .margin({ bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.categories, (category: Category) => {
            Text(category.icon + ' ' + category.name)
              .fontSize(14)
              .fontColor(this.selectedCategory === category.name ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedCategory === category.name ? '#2196F3' : '#F0F0F0')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 10, bottom: 10 })
              .onClick(() => {
                this.selectedCategory = category.name
              })
          })
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 24 })

      Column() {
        Text('备注')
          .fontSize(13)
          .fontColor('#757575')
          .width('100%')
          .margin({ bottom: 12 })

        TextInput({ placeholder: '请输入备注信息', text: this.title })
          .fontSize(15)
          .fontColor('#1A1A1A')
          .backgroundColor('#F5F5F5')
          .borderRadius(6)
          .height(48)
          .onChange((value: string) => {
            this.title = value
          })
      }
      .width('100%')
      .margin({ bottom: 24 })

      Column() {
        Text('日期')
          .fontSize(13)
          .fontColor('#757575')
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          Text(this.selectedDate)
            .fontSize(15)
            .fontColor('#1A1A1A')
            .layoutWeight(1)

          Button('选择')
            .fontSize(13)
            .backgroundColor('#2196F3')
            .borderRadius(4)
            .height(32)
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date('2020-01-01'),
                end: new Date('2030-12-31'),
                selected: new Date(this.selectedDate),
                onAccept: (value: DatePickerResult) => {
                  if (value.year !== undefined && value.month !== undefined && value.day !== undefined) {
                    this.selectedDate = `${value.year}-${String(value.month + 1).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`
                  }
                }
              })
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(6)
      }
      .width('100%')
      .margin({ bottom: 32 })

      Button('保存')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor('#2196F3')
        .borderRadius(6)
        .onClick(async () => {
          await this.onSave()
        })
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
