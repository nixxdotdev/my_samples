const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'store.json');

const INITIAL_SAMPLES = [
  // 1. Pending Approval
  {
    id: '1',
    title: 'Wireless ANC Noise-Cancelling Headphones',
    category: 'Electronics & Audio',
    remainingDays: 0,
    totalDays: 0,
    status: 'pendingApproval',
    createdAt: new Date().toISOString(),
  },
  {
    id: '2',
    title: 'Hydrating Peptide Glow Serum & Mist',
    category: 'Beauty & Skincare',
    remainingDays: 0,
    totalDays: 0,
    status: 'pendingApproval',
    createdAt: new Date().toISOString(),
  },
  {
    id: '3',
    title: 'Oversized Heavyweight Vintage Boxy Tee',
    category: 'Apparel & Fashion',
    remainingDays: 0,
    totalDays: 0,
    status: 'pendingApproval',
    createdAt: new Date().toISOString(),
  },
  {
    id: '4',
    title: 'Portable Cold Brew & Espresso Tumbler Maker',
    category: 'Home & Kitchen',
    remainingDays: 0,
    totalDays: 0,
    status: 'pendingApproval',
    createdAt: new Date().toISOString(),
  },

  // 2. Approved Samples
  {
    id: '5',
    title: 'Smart Health & Sleep Tracker Fitness Band',
    category: 'Gadgets & Fitness',
    remainingDays: 5,
    totalDays: 14,
    status: 'approved',
    createdAt: new Date().toISOString(),
  },
  {
    id: '6',
    title: 'Custom Hot-Swappable Mechanical Keyboard',
    category: 'Computer & Office',
    remainingDays: 7,
    totalDays: 14,
    status: 'approved',
    createdAt: new Date().toISOString(),
  },
  {
    id: '7',
    title: 'Vitamin C Brightening Daily Cleanser Foam',
    category: 'Personal Care',
    remainingDays: 8,
    totalDays: 14,
    status: 'approved',
    createdAt: new Date().toISOString(),
  },
  {
    id: '8',
    title: 'Creator Magnetic Ring Light & Tripod Stand',
    category: 'Creator Studio Gear',
    remainingDays: 10,
    totalDays: 14,
    status: 'approved',
    createdAt: new Date().toISOString(),
  },

  // 3. Pending Criteria / Posted
  {
    id: '9',
    title: 'Minimalist RFID Slim Leather Card Wallet',
    category: 'Accessories & Travel',
    remainingDays: 12,
    totalDays: 14,
    status: 'pendingCriteria',
    createdAt: new Date().toISOString(),
  },
  {
    id: '10',
    title: 'MagSafe Fast Wireless Power Bank 10000mAh',
    category: 'Mobile & Tech',
    remainingDays: 14,
    totalDays: 14,
    status: 'pendingCriteria',
    createdAt: new Date().toISOString(),
  },
  {
    id: '11',
    title: 'Matte Ceramic Pour-Over Coffee Dripper',
    category: 'Home & Kitchen',
    remainingDays: 6,
    totalDays: 14,
    status: 'pendingCriteria',
    createdAt: new Date().toISOString(),
  },
  {
    id: '12',
    title: 'Ergonomic Memory Foam Keyboard Wrist Rest',
    category: 'Computer & Office',
    remainingDays: 9,
    totalDays: 14,
    status: 'pendingCriteria',
    createdAt: new Date().toISOString(),
  },
];

const INITIAL_NOTIFICATIONS = [
  {
    id: 'n1',
    title: 'Sample Review Due in 2 Days!',
    description:
      'Your video post for Wireless ANC Headphones is due before Oct 12, 11:59 PM.',
    timeAgo: '25m ago',
    type: 'urgent',
    isRead: false,
    createdAt: new Date().toISOString(),
  },
  {
    id: 'n2',
    title: 'Sample Request Approved',
    description:
      'Merchant approved your request for Hydrating Peptide Glow Serum. Delivery in progress.',
    timeAgo: '2h ago',
    type: 'approved',
    isRead: false,
    createdAt: new Date().toISOString(),
  },
  {
    id: 'n3',
    title: 'Sample Package Dispatched',
    description:
      'Custom Mechanical Keyboard has shipped via J&T Express (Tracking #TK-98421).',
    timeAgo: '5h ago',
    type: 'shipping',
    isRead: false,
    createdAt: new Date().toISOString(),
  },
  {
    id: 'n4',
    title: 'Posting Criteria Guidelines',
    description:
      'Please ensure the official TikTok Shop product anchor tag is linked in your video caption.',
    timeAgo: '1d ago',
    type: 'guidelines',
    isRead: true,
    createdAt: new Date().toISOString(),
  },
  {
    id: 'n5',
    title: 'New Brand Collaboration Offer',
    description:
      'A brand invited you to request a free Creator Magnetic Ring Light sample.',
    timeAgo: '2d ago',
    type: 'offer',
    isRead: true,
    createdAt: new Date().toISOString(),
  },
];

class MockStore {
  constructor() {
    this.samples = [];
    this.notifications = [];
    this._load();
  }

  _load() {
    try {
      if (fs.existsSync(DATA_FILE)) {
        const raw = fs.readFileSync(DATA_FILE, 'utf8');
        const data = JSON.parse(raw);
        this.samples = Array.isArray(data.samples) ? data.samples : [...INITIAL_SAMPLES];
        this.notifications = Array.isArray(data.notifications) ? data.notifications : [...INITIAL_NOTIFICATIONS];
        return;
      }
    } catch (e) {
      console.warn('Failed to read store.json, falling back to initial seed data.', e.message);
    }
    this.samples = [...INITIAL_SAMPLES];
    this.notifications = [...INITIAL_NOTIFICATIONS];
    this._save();
  }

  _save() {
    try {
      fs.writeFileSync(
        DATA_FILE,
        JSON.stringify(
          {
            samples: this.samples,
            notifications: this.notifications,
            updatedAt: new Date().toISOString(),
          },
          null,
          2
        ),
        'utf8'
      );
    } catch (e) {
      console.error('Failed to save store.json:', e.message);
    }
  }

  // ================= SAMPLE METHODS =================

  async getAllSamples(filters = {}) {
    let result = [...this.samples];

    if (filters.status) {
      result = result.filter(
        (s) => s.status.toLowerCase() === filters.status.toLowerCase()
      );
    }

    if (filters.category) {
      result = result.filter(
        (s) => s.category.toLowerCase() === filters.category.toLowerCase()
      );
    }

    if (filters.search) {
      const q = filters.search.toLowerCase();
      result = result.filter(
        (s) =>
          s.title.toLowerCase().includes(q) ||
          s.category.toLowerCase().includes(q)
      );
    }

    return result;
  }

  async getSampleById(id) {
    return this.samples.find((s) => s.id === String(id)) || null;
  }

  async createSample(sampleData) {
    const id = sampleData.id || String(Date.now());
    const newSample = {
      id: String(id),
      title: sampleData.title || '',
      category: sampleData.category || 'Electronics & Audio',
      remainingDays: Number(sampleData.remainingDays || 0),
      totalDays: Number(sampleData.totalDays || 0),
      status: sampleData.status || 'pendingApproval',
      createdAt: new Date().toISOString(),
    };

    this.samples.unshift(newSample);
    this._save();
    return newSample;
  }

  async updateSampleStatus(id, updateData) {
    const index = this.samples.findIndex((s) => s.id === String(id));
    if (index === -1) return null;

    if (updateData.status) {
      this.samples[index].status = updateData.status;
    }
    if (updateData.remainingDays !== undefined) {
      this.samples[index].remainingDays = Number(updateData.remainingDays);
    }
    if (updateData.totalDays !== undefined) {
      this.samples[index].totalDays = Number(updateData.totalDays);
    }
    this.samples[index].updatedAt = new Date().toISOString();

    this._save();
    return this.samples[index];
  }

  async deleteSample(id) {
    const index = this.samples.findIndex((s) => s.id === String(id));
    if (index === -1) return false;

    this.samples.splice(index, 1);
    this._save();
    return true;
  }

  // ================= NOTIFICATION METHODS =================

  async getAllNotifications() {
    return [...this.notifications];
  }

  async getNotificationById(id) {
    return this.notifications.find((n) => n.id === String(id)) || null;
  }

  async markNotificationRead(id) {
    const item = this.notifications.find((n) => n.id === String(id));
    if (!item) return null;

    item.isRead = true;
    item.updatedAt = new Date().toISOString();
    this._save();
    return item;
  }

  async markAllNotificationsRead() {
    this.notifications.forEach((n) => {
      n.isRead = true;
    });
    this._save();
    return true;
  }

  // ================= ANALYTICS =================

  async getAnalyticsSummary() {
    const pendingCount = this.samples.filter(
      (s) => s.status === 'pendingApproval'
    ).length;
    const approvedCount = this.samples.filter(
      (s) => s.status === 'approved'
    ).length;
    const postedCount = this.samples.filter(
      (s) => s.status === 'pendingCriteria'
    ).length;

    return {
      total: this.samples.length,
      pendingCount,
      approvedCount,
      postedCount,
    };
  }

  // Reset to initial seed data
  reset() {
    this.samples = [...INITIAL_SAMPLES];
    this.notifications = [...INITIAL_NOTIFICATIONS];
    this._save();
  }
}

// Export singleton instance
module.exports = new MockStore();
