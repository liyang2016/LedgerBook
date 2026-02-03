import { DataManager, Category } from '../services/DataManager'
import { BottomNavBar } from '../components/BottomNavBar'
import router from '@ohos.router'

@Entry
@Component
struct CategoryManager {
  @State categories: Category[] = []
  @State currentTab: 'income' | 'expense' = 'expense'
  @State showAddDialog: boolean = false
  @State newCategoryName: string = ''
  @State newCategoryIcon: string = ''
  private dataManager: DataManager = DataManager.getInstance()

  async aboutToAppear(): Promise<void> {
    await this.loadCategories()
  }

  async loadCategories(): Promise<void> {
    this.categories = await this.dataManager.getCategories()
  }

  getFilteredCategories(): Category[] {
    return this.categories.filter(cat => cat.type === this.currentTab)
  }

  getAvailableIcons(): string[] {
    const usedIcons = this.categories.map(cat => cat.icon)
    const allIcons = ['🍔', '🚗', '🛒', '🎮', '💊', '📚', '🏠', '💰', '🎁', '📈', '💼', '☕', '🍿', '✈️', '💻', '🎬', '🏃', '💇', '🎵', '📱', '🌟', '🎨', '🍕', '🚇']
    return allIcons.filter(icon => !usedIcons.includes(icon))
  }

  async addCategory(): Promise<void> {
    if (!this.newCategoryName || !this.newCategoryIcon) {
      return
    }

    const newCategory: Category = {
      name: this.newCategoryName,
      icon: this.newCategoryIcon,
      type: this.currentTab
    }

    this.categories.push(newCategory)
    await this.dataManager.saveCategories(this.categories)
    await this.loadCategories()
    this.showAddDialog = false
    this.newCategoryName = ''
    this.newCategoryIcon = ''
  }

  async deleteCategory(category: Category): Promise<void> {
    const index = this.categories.findIndex(cat => cat.name === category.name && cat.type === category.type)
    if (index !== -1) {
      this.categories.splice(index, 1)
      await this.dataManager.saveCategories(this.categories)
      await this.loadCategories()
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('分类管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button() {
            Text('+')
              .fontSize(22)
              .fontColor('#FFFFFF')
          }
          .width(40)
          .height(40)
          .backgroundColor('#2196F3')
          .borderRadius(8)
          .onClick(() => {
            this.showAddDialog = true
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')

        Row() {
          Button('支出')
            .width('48%')
            .height(40)
            .backgroundColor(this.currentTab === 'expense' ? '#F44336' : '#F0F0F0')
            .fontColor(this.currentTab === 'expense' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(() => {
              this.currentTab = 'expense'
            })

          Button('收入')
            .width('48%')
            .height(40)
            .backgroundColor(this.currentTab === 'income' ? '#4CAF50' : '#F0F0F0')
            .fontColor(this.currentTab === 'income' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(() => {
              this.currentTab = 'income'
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.getFilteredCategories().length === 0) {
          Column() {
            Text('暂无分类')
              .fontSize(16)
              .fontColor('#9E9E9E')
              .margin({ top: 40 })
            Text('点击右上角"+"添加分类')
              .fontSize(14)
              .fontColor('#BDBDBD')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
        } else {
          List({ space: 8 }) {
            ForEach(this.getFilteredCategories(), (category: Category) => {
              ListItem() {
                Row() {
                  Text(category.icon)
                    .fontSize(28)

                  Text(category.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1A1A1A')
                    .margin({ left: 16 })

                  Blank()

                  Button() {
                    Text('删除')
                      .fontSize(13)
                      .fontColor('#F44336')
                  }
                  .backgroundColor('#FFEBEE')
                  .height(32)
                  .padding({ left: 14, right: 14 })
                  .borderRadius(4)
                  .onClick(() => {
                    this.deleteCategory(category)
                  })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#F5F5F5')
                .borderRadius(6)
                .border({ width: 1, color: '#EEEEEE' })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 16 })
        }

        // 底部导航栏占位
        Blank()
          .height(56)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')

      if (this.showAddDialog) {
        Column() {
          Column() {
            Text('添加分类')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .width('100%')
              .margin({ bottom: 24 })

            Column() {
              Text('分类名称')
                .fontSize(13)
                .fontColor('#757575')
                .width('100%')
                .margin({ bottom: 12 })

              TextInput({ placeholder: '请输入分类名称', text: this.newCategoryName })
                .fontSize(15)
                .fontColor('#1A1A1A')
                .backgroundColor('#F5F5F5')
                .borderRadius(6)
                .height(48)
                .onChange((value: string) => {
                  this.newCategoryName = value
                })
            }
            .width('100%')
            .margin({ bottom: 24 })

            Column() {
              Text('选择图标')
                .fontSize(13)
                .fontColor('#757575')
                .width('100%')
                .margin({ bottom: 16 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.getAvailableIcons(), (icon: string) => {
                  Text(icon)
                    .fontSize(28)
                    .padding(12)
                    .backgroundColor(this.newCategoryIcon === icon ? '#2196F3' : '#F0F0F0')
                    .borderRadius(6)
                    .margin({ right: 10, bottom: 10 })
                    .onClick(() => {
                      this.newCategoryIcon = icon
                    })
                })
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 32 })

            Row() {
              Button('取消')
                .width('48%')
                .height(48)
                .fontSize(16)
                .fontColor('#757575')
                .backgroundColor('#F0F0F0')
                .borderRadius(6)
                .onClick(() => {
                  this.showAddDialog = false
                  this.newCategoryName = ''
                  this.newCategoryIcon = ''
                })

              Button('添加')
                .width('48%')
                .height(48)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#2196F3')
                .borderRadius(6)
                .onClick(async () => {
                  await this.addCategory()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showAddDialog = false
        })
      }

      // 底部导航栏固定在底部
      Column() {
        BottomNavBar({ currentPageIndex: 2 })
      }
      .width('100%')
      .height(56)
      .position({ x: 0, y: '100%' })
      .translate({ y: -56 })
      .zIndex(100)
    }
    .width('100%')
    .height('100%')
  }
}
