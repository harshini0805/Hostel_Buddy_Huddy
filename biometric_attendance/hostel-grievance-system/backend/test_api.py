#!/usr/bin/env python3
"""
Test script for Hostel Grievance System API - Phase 1
Tests ticket creation endpoint and database storage
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"
HEADERS = {"Content-Type": "application/json"}


def print_section(title):
    """Print formatted section header"""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)


def test_health_check():
    """Test health check endpoint"""
    print_section("Testing Health Check")
    
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print("❌ Health check failed")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def test_create_ticket(test_case):
    """Test ticket creation with given test case"""
    print_section(f"Testing: {test_case['name']}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/tickets",
            headers=HEADERS,
            json=test_case['data']
        )
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 201:
            result = response.json()
            print("✅ Ticket created successfully!")
            print(f"\nTicket Details:")
            print(f"  ID: {result['id']}")
            print(f"  Student: {result['student']['name']} ({result['student']['id']})")
            print(f"  Location: {result['location']['hostel']}, Block {result['location']['block']}, Room {result['location']['room']}")
            print(f"  Category: {result['category']}")
            print(f"  Impact: {result['impact_radius']}")
            print(f"  Urgency: {result['urgency']}")
            print(f"  Vendor: {result['assigned_vendor']}")
            print(f"  Priority Score: {result['priority_score']}")
            print(f"  Status: {result['status']}")
            print(f"  Votes: {result['votes']['count']}")
            return True
        else:
            print(f"❌ Failed to create ticket")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("  HOSTEL GRIEVANCE SYSTEM - API TEST SUITE")
    print("  Phase 1: Ticket Creation MVP")
    print("="*60)
    print(f"Testing API at: {BASE_URL}")
    print(f"Time: {datetime.now().isoformat()}")
    
    # Test cases
    test_cases = [
        {
            "name": "High Priority Plumbing Issue (Hostel-wide)",
            "data": {
                "category": "plumbing",
                "impact_radius": "hostel",
                "urgency": "high",
                "description": "Main water line burst near the hostel entrance. Water flooding the ground floor corridors and affecting all blocks.",
                "media_urls": []
            }
        },
        {
            "name": "Medium Priority Electrical Issue (Floor-wide)",
            "data": {
                "category": "electrical",
                "impact_radius": "floor",
                "urgency": "medium",
                "description": "Power fluctuations on 3rd floor causing frequent tripping of MCB. Affecting study during evening hours.",
                "media_urls": []
            }
        },
        {
            "name": "Low Priority Civil Issue (Single Room)",
            "data": {
                "category": "civil",
                "impact_radius": "room",
                "urgency": "low",
                "description": "Door handle of room 312 is loose and needs tightening. Not urgent but should be fixed soon.",
                "media_urls": []
            }
        },
        {
            "name": "High Priority Safety Issue (Hostel-wide)",
            "data": {
                "category": "safety",
                "impact_radius": "hostel",
                "urgency": "high",
                "description": "Fire extinguisher in Block B is expired since last month. This is a major safety concern for all residents.",
                "media_urls": []
            }
        },
        {
            "name": "Medium Priority Internet Issue (Floor-wide)",
            "data": {
                "category": "internet",
                "impact_radius": "floor",
                "urgency": "medium",
                "description": "WiFi router on 2nd floor is not working properly. Intermittent connectivity issues affecting online classes.",
                "media_urls": []
            }
        }
    ]
    
    # Run tests
    results = []
    
    # 1. Health check
    health_ok = test_health_check()
    results.append(("Health Check", health_ok))
    
    if not health_ok:
        print("\n❌ Health check failed. Please ensure:")
        print("   1. Backend server is running (python main.py)")
        print("   2. MongoDB is running")
        print("   3. Port 8000 is accessible")
        return
    
    # 2. Create tickets
    for test_case in test_cases:
        success = test_create_ticket(test_case)
        results.append((test_case['name'], success))
    
    # Print summary
    print_section("TEST SUMMARY")
    print(f"\nTotal Tests: {len(results)}")
    print(f"Passed: {sum(1 for _, success in results if success)}")
    print(f"Failed: {sum(1 for _, success in results if not success)}")
    
    print("\nDetailed Results:")
    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"  {status} - {name}")
    
    # Overall result
    all_passed = all(success for _, success in results)
    
    print("\n" + "="*60)
    if all_passed:
        print("  ✅ ALL TESTS PASSED!")
        print("  Phase 1 MVP is working correctly.")
    else:
        print("  ❌ SOME TESTS FAILED")
        print("  Please check the error messages above.")
    print("="*60 + "\n")


if __name__ == "__main__":
    main()
