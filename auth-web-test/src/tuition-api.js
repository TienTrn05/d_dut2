// Bốn GET học phí: mỗi nút gọi đúng một endpoint, không thay thế bằng GET khác.
export const tuitionBaseUrl = "https://hocphi.dut.udn.vn";

export const tuitionEndpoints = {
  tuition: {
    title: "Tất cả học phí",
    service: "tuition",
    path: "/api/tuation_fees",
  },
  pending: {
    title: "Học phí cần nộp",
    service: "tuition",
    path: "/api/tuation_fees/pending",
  },
  paid: {
    title: "Học phí đã nộp",
    service: "tuition",
    path: "/api/tuation_fees/paid",
  },
  subjectFees: {
    title: "Học phí theo học phần",
    service: "tuition",
    path: "/api/tuation_fees/by-subject",
  },
};
