const assert = require('assert');
const http = require('http');
const app = require('../app');
const store = require('../database/mockStore');

async function runTests() {
  console.log('--- Starting Backend API Test Suite ---');

  // Reset store before test
  store.reset();

  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}`;

  async function request(path, options = {}) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, baseUrl);
      const reqOptions = {
        method: options.method || 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(options.headers || {}),
        },
      };

      const req = http.request(url, reqOptions, (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          let data;
          try {
            data = JSON.parse(body);
          } catch (_) {
            data = body;
          }
          resolve({ status: res.statusCode, data });
        });
      });

      req.on('error', reject);

      if (options.body) {
        req.write(JSON.stringify(options.body));
      }
      req.end();
    });
  }

  try {
    // 1. Root & Health Check
    console.log('Test 1: Health check endpoint');
    const health = await request('/api/health');
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.data.status, 'ok');
    console.log('  Passed: /api/health returns 200 OK');

    // 2. Samples GET
    console.log('Test 2: Retrieve all samples');
    const samplesRes = await request('/api/samples');
    assert.strictEqual(samplesRes.status, 200);
    assert.strictEqual(Array.isArray(samplesRes.data), true);
    assert.strictEqual(samplesRes.data.length, 12);
    console.log(`  Passed: /api/samples returned ${samplesRes.data.length} seeded samples`);

    // 3. Samples Filter by status
    console.log('Test 3: Filter samples by status');
    const approvedRes = await request('/api/samples?status=approved');
    assert.strictEqual(approvedRes.status, 200);
    assert.strictEqual(approvedRes.data.length, 4);
    assert(approvedRes.data.every((s) => s.status === 'approved'));
    console.log('  Passed: Filter ?status=approved returned 4 samples');

    // 4. Samples Create POST
    console.log('Test 4: Create a new sample');
    const newSamplePayload = {
      title: 'Studio Condenser Mic Kit',
      category: 'Electronics & Audio',
      remainingDays: 0,
      totalDays: 0,
      status: 'pendingApproval',
    };
    const createRes = await request('/api/samples', {
      method: 'POST',
      body: newSamplePayload,
    });
    assert.strictEqual(createRes.status, 201);
    assert.strictEqual(createRes.data.title, 'Studio Condenser Mic Kit');
    assert(createRes.data.id);
    const createdId = createRes.data.id;
    console.log(`  Passed: POST /api/samples created sample with ID ${createdId}`);

    // 5. Sample Update Status PATCH
    console.log('Test 5: Update sample status');
    const updateRes = await request(`/api/samples/${createdId}/status`, {
      method: 'PATCH',
      body: {
        status: 'approved',
        remainingDays: 14,
        totalDays: 14,
      },
    });
    assert.strictEqual(updateRes.status, 200);
    assert.strictEqual(updateRes.data.status, 'approved');
    assert.strictEqual(updateRes.data.remainingDays, 14);
    console.log('  Passed: PATCH /api/samples/:id/status transitioned sample to approved');

    // 6. Sample DELETE
    console.log('Test 6: Delete created sample');
    const deleteRes = await request(`/api/samples/${createdId}`, {
      method: 'DELETE',
    });
    assert.strictEqual(deleteRes.status, 200);
    assert.strictEqual(deleteRes.data.success, true);
    console.log('  Passed: DELETE /api/samples/:id removed sample');

    // 7. Notifications GET
    console.log('Test 7: Retrieve notifications');
    const notifsRes = await request('/api/notifications');
    assert.strictEqual(notifsRes.status, 200);
    assert.strictEqual(Array.isArray(notifsRes.data), true);
    assert.strictEqual(notifsRes.data.length, 5);
    console.log(`  Passed: /api/notifications returned ${notifsRes.data.length} notifications`);

    // 8. Notifications Mark Read PATCH
    console.log('Test 8: Mark single notification read');
    const markReadRes = await request('/api/notifications/n1/read', {
      method: 'PATCH',
    });
    assert.strictEqual(markReadRes.status, 200);
    assert.strictEqual(markReadRes.data.isRead, true);
    console.log('  Passed: PATCH /api/notifications/:id/read marked notification n1 as read');

    // 9. Notifications Mark All Read PATCH
    console.log('Test 9: Mark all notifications read');
    const markAllRes = await request('/api/notifications/read-all', {
      method: 'PATCH',
    });
    assert.strictEqual(markAllRes.status, 200);
    assert.strictEqual(markAllRes.data.success, true);
    console.log('  Passed: PATCH /api/notifications/read-all marked all as read');

    // 10. Analytics Summary GET
    console.log('Test 10: Analytics summary');
    const summaryRes = await request('/api/analytics/summary');
    assert.strictEqual(summaryRes.status, 200);
    assert.strictEqual(summaryRes.data.total, 12);
    assert.strictEqual(summaryRes.data.pendingCount, 4);
    assert.strictEqual(summaryRes.data.approvedCount, 4);
    assert.strictEqual(summaryRes.data.postedCount, 4);
    console.log('  Passed: /api/analytics/summary returned correct counts');

    // 11. Swagger Spec Verification
    console.log('Test 11: Swagger spec endpoint');
    const swaggerRes = await request('/api-docs.json');
    assert.strictEqual(swaggerRes.status, 200);
    assert.strictEqual(swaggerRes.data.openapi, '3.0.0');
    const documentedPaths = Object.keys(swaggerRes.data.paths || {});
    console.log(`  Passed: Swagger documentation has ${documentedPaths.length} endpoints:`, documentedPaths);
    assert(documentedPaths.length >= 8, 'Expected at least 8 endpoints in Swagger spec');

    console.log('\n--- ALL 11 BACKEND TESTS PASSED! ---');
  } finally {
    server.close();
  }
}

runTests().catch((err) => {
  console.error('Test execution failed:', err);
  process.exit(1);
});
