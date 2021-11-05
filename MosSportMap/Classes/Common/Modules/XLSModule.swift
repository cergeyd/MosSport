//
//  XLSModule.swift
//  MosSportMap
//
//  Created by Sergey D on 04.11.2021.
//

import xlsxwriter
import UIKit

class XLSModule {

    private let presenter: UIViewController
    private var url: URL? = nil

    //MARK: Init
    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    // MARK: Create Sheet
    func createXLS(with name: String, report: SquareReport) {
        let path = getPath(createFile: name)
        let workbook = workbook_new(path)
        let worksheet = workbook_add_worksheet(workbook, name)

        /// Format : Means set properties to row, column & cell
        let formatHeader = setupFormatHeader(using: workbook)
        self.setupHeader(using: worksheet, myformatBold: formatHeader)
        let formatAllignCenter = setupFormatCenterAllign(using: workbook)
        let departments = report.departments.count
        let objects = report.objects.count
        let sportTypes = report.sportTypes.count
        /// Отсутсвующие виды спорта
        let miss = SharedManager.shared.missingSportTypes(objects: report.objects)
        /// Сколько МАХ ячеек нужно
        let max = max(departments, objects, sportTypes, miss.count)

        for i in 0..<max {
            let serialNumber = i + 2
            let row = lxw_row_t(serialNumber)

            /// Высота
            worksheet_set_row(worksheet, lxw_row_t(i), 20, formatAllignCenter)

            /// Ширина
            worksheet_set_column(worksheet, 0, 0, 30, formatAllignCenter)
            worksheet_set_column(worksheet, 1, 1, 25, formatAllignCenter)
            worksheet_set_column(worksheet, 2, 2, 20, formatAllignCenter)
            worksheet_set_column(worksheet, 3, 3, 20, formatAllignCenter)

            worksheet_set_column(worksheet, 4, 4, 30, formatAllignCenter)
            worksheet_set_column(worksheet, 5, 5, 25, formatAllignCenter)
            worksheet_set_column(worksheet, 6, 6, 25, formatAllignCenter)
            worksheet_set_column(worksheet, 7, 7, 55, formatAllignCenter)
            worksheet_set_column(worksheet, 8, 8, 75, formatAllignCenter)
            worksheet_set_column(worksheet, 9, 9, 55, formatAllignCenter)
            worksheet_set_column(worksheet, 10, 10, 55, formatAllignCenter)

            if (row == 2) {
                /// Район
                worksheet_write_string(worksheet, row, 0, report.population.area, formatAllignCenter)
                /// Плотность
                worksheet_write_number(worksheet, row, 1, report.population.population, formatAllignCenter)
                /// Площадь
                worksheet_write_number(worksheet, row, 2, report.population.square / gSquareToKilometers, formatAllignCenter)
                /// Площадь объектов
                worksheet_write_number(worksheet, row, 3, report.allSquare, formatAllignCenter)
                /// Относительные величины
                worksheet_write_number(worksheet, row, 4, report.squareForOne, formatAllignCenter)
                worksheet_write_number(worksheet, row, 5, report.objectForOne, formatAllignCenter)
                worksheet_write_number(worksheet, row, 6, report.sportTypeForOne, formatAllignCenter)
            }

            if (row > 1) {
                /// Департаменты
                if (report.departments.count - 1 >= i) {
                    let department = report.departments[i]
                    worksheet_write_string(worksheet, row, 7, department.title + ". ID: \(department.id)", nil)
                }
                /// Объекты
                if (report.objects.count - 1 >= i) {
                    let object = report.objects[i]
                    worksheet_write_string(worksheet, row, 8, object.title + ". ID: \(object.id)", nil)
                }
                /// Виды спорта
                if (report.sportTypes.count - 1 >= i) {
                    let sport = report.sportTypes[i]
                    worksheet_write_string(worksheet, row, 9, sport.title, nil)
                }
                if (miss.count - 1 >= i) {
                    let mi = miss[i]
                    worksheet_write_string(worksheet, row, 10, mi.title, nil)
                }
            }
        }

        /// Save and close editing & generate physical file in document directory, If already exist then It will replace it
        workbook_close(workbook)

        Dispatch.after(8.0) {
            if let sourceView = self.presenter.navigationItem.rightBarButtonItem {
                self.show(sourceView: sourceView)
            }
        }
    }

    /// Share
    private func show(sourceView: UIBarButtonItem) {
        var filesToShare = [Any]()
        if let url = self.url {
            filesToShare.append(url)
            /// Make the activityViewContoller which shows the share-view
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sourceView
            /// Show the share-view
            self.presenter.present(activityViewController, animated: true, completion: nil)
        }
    }

    func getPath(createFile fileName: String) -> UnsafePointer<Int8> {
        self.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName).appendingPathExtension("xlsx")
        let path = NSString(string: url!.path).fileSystemRepresentation
        print("path:", url!.absoluteString)
        return path
    }
}

// MARK: Set theme, Text, Allignment, Width, Style, Etc using lxw_format
extension XLSModule {
    func setupFormatText(using workbook: UnsafeMutablePointer<lxw_workbook>?) -> UnsafeMutablePointer<lxw_format>? {
        let myformatNormal = workbook_add_format(workbook)
        format_set_align(myformatNormal, UInt8(LXW_ALIGN_VERTICAL_DISTRIBUTED.rawValue))
        format_set_text_wrap(myformatNormal);
        return myformatNormal
    }

    func setupFormatHeader(using workbook: UnsafeMutablePointer<lxw_workbook>?) -> UnsafeMutablePointer<lxw_format>? {
        let format = workbook_add_format(workbook)
        format_set_bold(format)
        format_set_align(format, UInt8(LXW_ALIGN_CENTER_ACROSS.rawValue))
        return format
    }

    func setupFormatRightAllign_Bold(using workbook: UnsafeMutablePointer<lxw_workbook>?) -> UnsafeMutablePointer<lxw_format>? {
        let format = workbook_add_format(workbook)
        format_set_bold(format)
        format_set_align(format, UInt8(LXW_ALIGN_RIGHT.rawValue))
        return format
    }

    func setupFormatCenterAllign(using workbook: UnsafeMutablePointer<lxw_workbook>?) -> UnsafeMutablePointer<lxw_format>? {
        let format = workbook_add_format(workbook)
        //        format_set_align(format, UInt8(LXW_ALIGN_CENTER.rawValue))
        //        format_set_align(format, UInt8(LXW_ALIGN_VERTICAL_CENTER.rawValue))
        format_set_align(format, UInt8(LXW_ALIGN_CENTER_ACROSS.rawValue))
        return format
    }

    func setupNumberFormat(using workbook: UnsafeMutablePointer<lxw_workbook>?) -> UnsafeMutablePointer<lxw_format>? {
        let formatDouble = workbook_add_format(workbook)
        format_set_num_format(formatDouble, "0.00");
        return formatDouble
    }

    func setupHeader(using worksheet: UnsafeMutablePointer<lxw_worksheet>?, myformatBold: UnsafeMutablePointer<lxw_format>?) {
        /// Район
        worksheet_write_string(worksheet, 0, 0, "Район", myformatBold)

        worksheet_write_string(worksheet, 0, 1, "Плотность населения/км²", myformatBold)
        worksheet_write_string(worksheet, 0, 2, "Площадь района. м²", myformatBold)
        worksheet_write_string(worksheet, 0, 3, "Площадь объектов. м²", myformatBold)
        /// Относительные величины
        worksheet_write_string(worksheet, 0, 4, "Относительные величины", myformatBold)
        worksheet_write_string(worksheet, 0, 5, "", myformatBold)
        worksheet_write_string(worksheet, 0, 6, "", myformatBold)

        worksheet_write_string(worksheet, 1, 4, "Площадь объектов/человека", myformatBold)
        worksheet_write_string(worksheet, 1, 5, "Объекты/человека", myformatBold)
        worksheet_write_string(worksheet, 1, 6, "Виды спорта/человека", myformatBold)
        /// Департаменты
        worksheet_write_string(worksheet, 0, 7, "Департаменты", myformatBold)
        /// Спортивные объекты
        worksheet_write_string(worksheet, 0, 8, "Спортивные объекты", myformatBold)
        /// Спортивные зоны
        worksheet_write_string(worksheet, 0, 9, "Спортивные зоны", myformatBold)
        worksheet_write_string(worksheet, 0, 10, "", myformatBold)
        /// Спортивные зоны | Присутствуют
        worksheet_write_string(worksheet, 1, 9, "Присутствуют", myformatBold)
        /// Спортивные зоны | Отсутствуют
        worksheet_write_string(worksheet, 1, 10, "Отсутствуют", myformatBold)

        worksheet_merge_range(worksheet, 0, 0, 1, 0, "Район", myformatBold)
        worksheet_merge_range(worksheet, 0, 1, 1, 1, "Плотность населения/км²", myformatBold)
        worksheet_merge_range(worksheet, 0, 2, 1, 2, "Площадь района. м²", myformatBold)
        worksheet_merge_range(worksheet, 0, 3, 1, 3, "Площадь объектов. м²", myformatBold)
        worksheet_merge_range(worksheet, 0, 7, 1, 7, "Департаменты", myformatBold)
        worksheet_merge_range(worksheet, 0, 8, 1, 8, "Спортивные объекты", myformatBold)
    }
}
